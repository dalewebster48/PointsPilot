import 'dotenv/config'
import Fastify from 'fastify'
import cors from '@fastify/cors'
import { Db } from '../shared/db'
import { airportRoutes } from './routes/airports'
import { routeRoutes } from './routes/routes'
import { flightRoutes } from './routes/flights'

const dbPath = process.env.DB_PATH || './database.db'
const port = parseInt(process.env.PORT || '4000')

const db = new Db(dbPath, true)
const fastify = Fastify({ logger: true })

async function start() {
    await fastify.register(cors)

    airportRoutes(fastify, db)
    routeRoutes(fastify, db)
    flightRoutes(fastify, db)

    await fastify.listen({ port, host: '0.0.0.0' })
    console.log(`Server listening on port ${port}`)
}

start().catch(err => {
    console.error('Server failed to start:', err)
    process.exit(1)
})
