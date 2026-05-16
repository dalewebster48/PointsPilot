import Database from 'better-sqlite3'
import { Airport, AirportFilter, RouteFilter, FlightFilter, SortOrder } from './types'
import { buildWhere, buildOrderBy, buildPagination, conditionsFromFilter } from './query-builder'

// --- Airports ---

const AIRPORT_SORT_FIELDS: Record<string, string> = {
    name: 'airports.name',
    country: 'airports.country'
}

export function queryAirports(
    db: Database.Database,
    filter?: AirportFilter,
    orderBy?: string,
    limit: number = -1,
    offset: number = 0
): Airport[] {
    const conditions = conditionsFromFilter(filter, [
        { key: 'name', column: 'airports.name', op: 'LIKE' },
        { key: 'country', column: 'airports.country', op: 'LIKE' },
    ])

    const where = buildWhere(conditions)
    const pagination = buildPagination(limit, offset)
    const [sortField, sortDir] = (orderBy?.split(':') ?? []) as [string?, SortOrder?]
    const order = sortField && AIRPORT_SORT_FIELDS[sortField]
        ? buildOrderBy(AIRPORT_SORT_FIELDS[sortField], sortDir ?? 'asc')
        : ''

    const query = `
        SELECT airports.id AS code, airports.name, airports.country, routes.end AS destination
        FROM airports
        LEFT JOIN routes ON routes.start = airports.id
        ${where.clause} ${order}
    `

    const rows = db.prepare(query).all(...where.params) as {
        code: string; name: string; country: string; destination: string | null
    }[]

    // Group rows by airport, collecting destinations
    const airportMap = new Map<string, Airport>()
    const airports: Airport[] = []

    for (const row of rows) {
        if (!airportMap.has(row.code)) {
            const airport: Airport = { code: row.code, name: row.name, country: row.country, destinations: [] }
            airportMap.set(row.code, airport)
            airports.push(airport)
        }
        if (row.destination) {
            airportMap.get(row.code)!.destinations.push(row.destination)
        }
    }

    // Apply pagination in JS since the JOIN produces multiple rows per airport
    return airports.slice(offset, limit === -1 ? undefined : offset + limit)
}

// --- Routes ---

const ROUTE_SORT_FIELDS: Record<string, string> = {
    origin: 'routes.start',
    destination: 'routes.end'
}

export function queryRoutes(
    db: Database.Database,
    filter?: RouteFilter,
    orderBy?: string,
    limit: number = -1,
    offset: number = 0
) {
    const conditions = conditionsFromFilter(filter, [
        { key: 'origin', column: 'routes.start', op: '=' },
        { key: 'destination', column: 'routes.end', op: '=' },
    ])

    const where = buildWhere(conditions)
    const pagination = buildPagination(limit, offset)
    const [sortField, sortDir] = (orderBy?.split(':') ?? []) as [string?, SortOrder?]
    const order = sortField && ROUTE_SORT_FIELDS[sortField]
        ? buildOrderBy(ROUTE_SORT_FIELDS[sortField], sortDir ?? 'asc')
        : ''

    const query = `
        SELECT routes.id, routes.start, routes.end,
               sa.id AS start_id, sa.name AS start_name, sa.country AS start_country,
               ea.id AS end_id, ea.name AS end_name, ea.country AS end_country
        FROM routes
        LEFT JOIN airports AS sa ON routes.start = sa.id
        LEFT JOIN airports AS ea ON routes.end = ea.id
        ${where.clause} ${order} ${pagination.clause}
    `

    const rows = db.prepare(query).all(...where.params, ...pagination.params) as any[]
    return rows.map(row => ({
        id: row.id,
        origin: { id: row.start_id, name: row.start_name, country: row.start_country },
        destination: { id: row.end_id, name: row.end_name, country: row.end_country }
    }))
}

// --- Flights ---

const FLIGHT_SORT_FIELDS: Record<string, string> = {
    date: 'flights.date',
    economy: 'flights.economy_cost',
    premium: 'flights.premium_cost',
    upper: 'flights.upper_cost'
}

export function queryFlights(
    db: Database.Database,
    filter?: FlightFilter,
    orderBy?: string,
    orderDirection?: SortOrder,
    limit: number = 20,
    offset: number = 0
) {
    const conditions = conditionsFromFilter(filter, [
        { key: 'origin', column: 'flights.start', op: '=' },
        { key: 'destination', column: 'flights.end', op: '=' },
        { key: 'originCountry', column: 'sa.country', op: '=' },
        { key: 'destinationCountry', column: 'ea.country', op: '=' },
        { key: 'dateFrom', column: 'flights.date', op: '>=' },
        { key: 'dateTo', column: 'flights.date', op: '<=' },
        { key: 'economyCostMin', column: 'flights.economy_cost', op: '>=' },
        { key: 'economyCostMax', column: 'flights.economy_cost', op: '<=' },
        { key: 'premiumCostMin', column: 'flights.premium_cost', op: '>=' },
        { key: 'premiumCostMax', column: 'flights.premium_cost', op: '<=' },
        { key: 'upperCostMin', column: 'flights.upper_cost', op: '>=' },
        { key: 'upperCostMax', column: 'flights.upper_cost', op: '<=' },
    ])

    // Deal filters need special handling (boolean -> integer)
    if (filter?.economyDeal != null) conditions.push({ column: 'flights.economy_deal', op: '=', value: filter.economyDeal ? 1 : 0 })
    if (filter?.premiumDeal != null) conditions.push({ column: 'flights.premium_deal', op: '=', value: filter.premiumDeal ? 1 : 0 })
    if (filter?.upperDeal != null) conditions.push({ column: 'flights.upper_deal', op: '=', value: filter.upperDeal ? 1 : 0 })

    const sortColumn = orderBy ? FLIGHT_SORT_FIELDS[orderBy] : undefined
    if (sortColumn && orderBy !== 'date') {
        conditions.push({ column: sortColumn, op: '>', value: 0 })
    }

    const where = buildWhere(conditions)
    const order = sortColumn ? buildOrderBy(sortColumn, orderDirection ?? 'asc') : ''
    const pagination = buildPagination(limit, offset)

    const baseFrom = `
        FROM flights
        LEFT JOIN airports AS sa ON flights.start = sa.id
        LEFT JOIN airports AS ea ON flights.end = ea.id
    `

    // Get total count and per-cabin maxes
    const aggregateQuery = `
        SELECT COUNT(*) as total,
               MAX(flights.economy_cost) as maxEconomy,
               MAX(flights.premium_cost) as maxPremium,
               MAX(flights.upper_cost) as maxUpper
        ${baseFrom} ${where.clause}
    `
    const aggregate = db.prepare(aggregateQuery).get(...where.params) as {
        total: number
        maxEconomy: number | null
        maxPremium: number | null
        maxUpper: number | null
    } | undefined
    const total = aggregate?.total ?? 0
    const maxEconomy = aggregate?.maxEconomy ?? 0
    const maxPremium = aggregate?.maxPremium ?? 0
    const maxUpper = aggregate?.maxUpper ?? 0

    // Get paginated data
    const query = `
        SELECT flights.*,
               sa.id AS start_id, sa.name AS start_name, sa.country AS start_country,
               ea.id AS end_id, ea.name AS end_name, ea.country AS end_country
        ${baseFrom} ${where.clause} ${order} ${pagination.clause}
    `

    const rows = db.prepare(query).all(...where.params, ...pagination.params) as any[]
    const data = rows.map(row => ({
        id: row.id,
        date: row.date,
        origin: { id: row.start_id, name: row.start_name, country: row.start_country },
        destination: { id: row.end_id, name: row.end_name, country: row.end_country },
        economyCost: row.economy_cost,
        economyDeal: row.economy_deal === 1,
        premiumCost: row.premium_cost,
        premiumDeal: row.premium_deal === 1,
        upperCost: row.upper_cost,
        upperDeal: row.upper_deal === 1
    }))

    return { data, total, maxEconomy, maxPremium, maxUpper }
}
