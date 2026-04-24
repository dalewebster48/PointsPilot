import 'dotenv/config'
import cron from 'node-cron'
import { Db } from '../shared/db'
import { syncAirports } from './sync-airports'
import { syncFlights } from './sync-flights'
import { rsyncDatabase } from './rsync'

const dbPath = process.env.DB_PATH || './database.db'

async function runSync() {
    const db = new Db(dbPath)

    try {
        const airportsOk = await syncAirports(db)
        if (!airportsOk) {
            console.error('Airport sync failed, skipping flight sync')
            return
        }

        const flightsOk = await syncFlights(db)
        if (!flightsOk) {
            console.error('Flight sync failed, skipping rsync')
            return
        }

        rsyncDatabase(db)
    } finally {
        db.close()
    }
}

// Run immediately if --now flag is passed
if (process.argv.includes('--now')) {
    console.log('Running immediate sync...')
    runSync().catch(err => console.error('Sync error:', err))
}

// Schedule daily at 2AM
cron.schedule('0 2 * * *', () => {
    console.log('Starting scheduled sync...')
    runSync().catch(err => console.error('Scheduled sync error:', err))
})

console.log('Scraper scheduled for 2:00 AM daily')
