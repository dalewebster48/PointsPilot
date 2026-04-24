import { Db } from '../shared/db'
import { queryAirports } from '../shared/reads'
import { scrapeFlights } from './scrapers/flight-scraper'

type MonthYear = { month: string; year: number }

function getNext12Months(): MonthYear[] {
    const result: MonthYear[] = []
    const now = new Date()

    for (let i = 0; i < 12; i++) {
        const date = new Date(now.getFullYear(), now.getMonth() + i)
        result.push({
            month: String(date.getMonth() + 1).padStart(2, '0'),
            year: date.getFullYear()
        })
    }

    return result
}

export async function syncFlights(db: Db): Promise<boolean> {
    console.log('Starting flight sync...')

    try {
        db.initEphemeralFlights()

        const airports = queryAirports(db.connection)
        const months = getNext12Months()

        for (const airport of airports) {
            for (const destCode of airport.destinations) {
                for (const { month, year } of months) {
                    console.log(`Scraping ${airport.code} -> ${destCode} ${month}/${year}`)

                    const flights = await scrapeFlights(airport.code, destCode, month, year)

                    if (flights.length) {
                        db.insertFlights(flights, true)
                        console.log(`  Inserted ${flights.length} flights`)
                    } else {
                        console.log('  No flights found')
                    }
                }
            }
        }

        console.log('Swapping flight tables...')
        db.swapFlightsTables()
        console.log('Flight sync complete')

        return true
    } catch (error) {
        console.error('Flight sync failed:', error)
        try { db.cleanupEphemeral() } catch {}
        return false
    }
}
