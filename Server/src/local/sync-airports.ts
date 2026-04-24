import { Db } from '../shared/db'
import { scrapeAirports } from './scrapers/airport-scraper'

export async function syncAirports(db: Db): Promise<boolean> {
    console.log('Starting airport sync...')

    const airports = await scrapeAirports()

    if (!airports.length) {
        console.error('No airports found, skipping sync')
        return false
    }

    console.log(`Scraped ${airports.length} airports, writing to database...`)
    db.clearAirportsAndRoutes()
    db.insertAirports(airports)
    console.log('Airport sync complete')

    return true
}
