import { execSync } from 'child_process'
import { unlinkSync } from 'fs'
import { Db } from '../shared/db'

export function rsyncDatabase(db: Db): boolean {
    const target = process.env.RSYNC_TARGET
    const exportPath = process.env.RSYNC_EXPORT_PATH

    if (!target || !exportPath) {
        console.log('RSYNC_TARGET or RSYNC_EXPORT_PATH not set, skipping rsync')
        return false
    }

    try {
        console.log('Creating clean database export...')
        db.vacuumInto(exportPath)

        console.log(`Rsyncing to ${target}...`)
        execSync(`rsync -az ${exportPath} ${target}`, { stdio: 'inherit' })
        console.log('Rsync complete')

        return true
    } catch (error) {
        console.error('Rsync failed:', error)
        return false
    } finally {
        try { unlinkSync(exportPath) } catch {}
    }
}
