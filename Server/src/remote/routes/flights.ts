import { FastifyInstance } from 'fastify'
import { Db } from '../../shared/db'
import { FlightFilter } from '../../shared/types'
import { queryFlights } from '../../shared/reads'

export function flightRoutes(fastify: FastifyInstance, db: Db) {
    fastify.get('/flights', async (request) => {
        const q = request.query as Record<string, string | undefined>

        const parseMulti = (v: string): string | string[] =>
            v.includes(',') ? v.split(',') : v

        const filter: FlightFilter = {}
        if (q.origin) filter.origin = parseMulti(q.origin)
        if (q.destination) filter.destination = parseMulti(q.destination)
        if (q.originCountry) filter.originCountry = parseMulti(q.originCountry)
        if (q.destinationCountry) filter.destinationCountry = parseMulti(q.destinationCountry)
        if (q.dateFrom) filter.dateFrom = q.dateFrom
        if (q.dateTo) filter.dateTo = q.dateTo
        if (q.economyCostMin) filter.economyCostMin = parseInt(q.economyCostMin)
        if (q.economyCostMax) filter.economyCostMax = parseInt(q.economyCostMax)
        if (q.economyDeal) filter.economyDeal = q.economyDeal === 'true'
        if (q.premiumCostMin) filter.premiumCostMin = parseInt(q.premiumCostMin)
        if (q.premiumCostMax) filter.premiumCostMax = parseInt(q.premiumCostMax)
        if (q.premiumDeal) filter.premiumDeal = q.premiumDeal === 'true'
        if (q.upperCostMin) filter.upperCostMin = parseInt(q.upperCostMin)
        if (q.upperCostMax) filter.upperCostMax = parseInt(q.upperCostMax)
        if (q.upperDeal) filter.upperDeal = q.upperDeal === 'true'

        return queryFlights(
            db.connection,
            filter,
            q.orderBy,
            q.orderDirection as 'asc' | 'desc' | undefined,
            q.limit ? parseInt(q.limit) : undefined,
            q.offset ? parseInt(q.offset) : undefined
        )
    })
}
