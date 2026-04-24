import 'dotenv/config'
import { Db } from '../shared/db'
import { rsyncDatabase } from './rsync'

const dbPath = process.env.DB_PATH || './database.db'
const db = new Db(dbPath, true)

try {
    const ok = rsyncDatabase(db)
    process.exit(ok ? 0 : 1)
} finally {
    db.close()
}
