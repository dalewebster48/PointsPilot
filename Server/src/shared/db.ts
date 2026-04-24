import Database from 'better-sqlite3'
import { Airport, Flight } from './types'

export class Db {
    readonly connection: Database.Database

    constructor(dbPath: string, readonly: boolean = false) {
        this.connection = new Database(dbPath, { readonly })

        if (!readonly) {
            this.connection.pragma('journal_mode = WAL')
            this.createTables()
        }
    }

    private createTables() {
        this.connection.exec(`
            CREATE TABLE IF NOT EXISTS airports (
                id VARCHAR NOT NULL UNIQUE,
                name VARCHAR NOT NULL,
                country VARCHAR NOT NULL
            );
            CREATE TABLE IF NOT EXISTS routes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                start VARCHAR NOT NULL,
                end VARCHAR NOT NULL
            );
            CREATE TABLE IF NOT EXISTS flights (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT NOT NULL,
                start VARCHAR NOT NULL,
                end VARCHAR NOT NULL,
                economy_cost INTEGER NOT NULL,
                economy_deal INTEGER NOT NULL,
                premium_cost INTEGER NOT NULL,
                premium_deal INTEGER NOT NULL,
                upper_cost INTEGER NOT NULL,
                upper_deal INTEGER NOT NULL
            );
        `)
    }

    close() {
        this.connection.close()
    }

    // --- Write methods ---

    clearAirportsAndRoutes() {
        this.connection.exec('DELETE FROM routes; DELETE FROM airports;')
    }

    insertAirports(airports: Airport[]) {
        const insertAirport = this.connection.prepare(
            'INSERT OR IGNORE INTO airports (id, name, country) VALUES (?, ?, ?)'
        )
        const insertRoute = this.connection.prepare(
            'INSERT OR IGNORE INTO routes (start, end) VALUES (?, ?)'
        )

        this.connection.transaction((airports: Airport[]) => {
            for (const airport of airports) {
                insertAirport.run(airport.code, airport.name, airport.country)
                for (const dest of airport.destinations) {
                    insertRoute.run(airport.code, dest)
                }
            }
        })(airports)
    }

    initEphemeralFlights() {
        this.connection.exec(`
            CREATE TABLE IF NOT EXISTS flights_ephemeral (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT NOT NULL,
                start VARCHAR NOT NULL,
                end VARCHAR NOT NULL,
                economy_cost INTEGER NOT NULL,
                economy_deal INTEGER NOT NULL,
                premium_cost INTEGER NOT NULL,
                premium_deal INTEGER NOT NULL,
                upper_cost INTEGER NOT NULL,
                upper_deal INTEGER NOT NULL
            );
            DELETE FROM flights_ephemeral;
        `)
    }

    insertFlights(flights: Flight[], ephemeral: boolean = false) {
        const table = ephemeral ? 'flights_ephemeral' : 'flights'
        const insert = this.connection.prepare(`
            INSERT INTO ${table} (date, start, end, economy_cost, economy_deal, premium_cost, premium_deal, upper_cost, upper_deal)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `)

        this.connection.transaction((flights: Flight[]) => {
            for (const f of flights) {
                insert.run(
                    f.date, f.origin, f.destination,
                    f.economyCost, f.economyDeal ? 1 : 0,
                    f.premiumCost, f.premiumDeal ? 1 : 0,
                    f.upperCost, f.upperDeal ? 1 : 0
                )
            }
        })(flights)
    }

    swapFlightsTables() {
        this.connection.transaction(() => {
            this.connection.exec('DROP TABLE IF EXISTS flights')
            this.connection.exec('ALTER TABLE flights_ephemeral RENAME TO flights')
        })()
    }

    cleanupEphemeral() {
        this.connection.exec('DROP TABLE IF EXISTS flights_ephemeral')
    }

    vacuumInto(path: string) {
        this.connection.exec(`VACUUM INTO '${path}'`)
    }
}
