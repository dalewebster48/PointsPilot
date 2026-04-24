import { FastifyInstance } from 'fastify'
import { Db } from '../../shared/db'
import { queryRoutes } from '../../shared/reads'

export function routeRoutes(fastify: FastifyInstance, db: Db) {
    fastify.get('/routes', async (request) => {
        const { origin, destination, orderBy, limit, offset } = request.query as {
            origin?: string
            destination?: string
            orderBy?: string
            limit?: string
            offset?: string
        }

        const data = queryRoutes(
            db.connection,
            { origin, destination },
            orderBy,
            limit ? parseInt(limit) : undefined,
            offset ? parseInt(offset) : undefined
        )

        return { data }
    })
}
