import { FastifyInstance } from 'fastify'
import { Db } from '../../shared/db'
import { queryAirports } from '../../shared/reads'

export function airportRoutes(fastify: FastifyInstance, db: Db) {
    fastify.get('/airports', async (request) => {
        const { name, country, orderBy, limit, offset } = request.query as {
            name?: string
            country?: string
            orderBy?: string
            limit?: string
            offset?: string
        }

        const data = queryAirports(
            db.connection,
            { name, country },
            orderBy,
            limit ? parseInt(limit) : undefined,
            offset ? parseInt(offset) : undefined
        )

        return { data }
    })
}
