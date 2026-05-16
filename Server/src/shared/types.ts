export type Airport = {
    code: string
    name: string
    country: string
    destinations: string[]
}

export type Flight = {
    date: string
    origin: string
    destination: string
    economyCost: number
    economyDeal: boolean
    premiumCost: number
    premiumDeal: boolean
    upperCost: number
    upperDeal: boolean
}

export type Route = {
    id: number
    origin: string
    destination: string
}

export type FlightFilter = {
    origin?: string | string[]
    destination?: string | string[]
    originCountry?: string | string[]
    destinationCountry?: string | string[]
    dateFrom?: string
    dateTo?: string
    economyCostMin?: number
    economyCostMax?: number
    economyDeal?: boolean
    premiumCostMin?: number
    premiumCostMax?: number
    premiumDeal?: boolean
    upperCostMin?: number
    upperCostMax?: number
    upperDeal?: boolean
}

export type AirportFilter = {
    name?: string
    country?: string
}

export type RouteFilter = {
    origin?: string
    destination?: string
}

export type SortOrder = 'asc' | 'desc'
