import { Airport } from '../../shared/types'
import { puppeteer, getPuppeteerConfig } from '../puppeteer-config'

export async function scrapeAirports(): Promise<Airport[]> {
    let browser

    try {
        browser = await puppeteer.launch(getPuppeteerConfig())
        const page = await browser.newPage()

        await page.setViewport({
            width: 1366 + Math.floor(Math.random() * 100),
            height: 768 + Math.floor(Math.random() * 100)
        })

        page.setDefaultNavigationTimeout(20000)
        page.setDefaultTimeout(10000)

        console.log('Navigating to reward flight finder...')
        const response = await page.goto('https://www.virginatlantic.com/reward-flight-finder', {
            waitUntil: 'domcontentloaded',
            timeout: 20000
        })

        if (response?.status() === 403) {
            console.error('Blocked with 403')
            return []
        }

        try {
            await page.waitForSelector('#origin', { timeout: 15000 })
        } catch {
            console.error('Origin selector not found')
            return []
        }

        // Find the working origin selector
        let originSelector = '#origin'
        if (!await page.$('#origin')) {
            const alternatives = [
                'select[name*="origin"]',
                'select[id*="origin"]',
                'select[class*="origin"]',
                'select:first-of-type'
            ]
            for (const sel of alternatives) {
                if (await page.$(sel)) {
                    originSelector = sel
                    break
                }
            }
        }

        if (!await page.$(originSelector)) {
            console.error('Could not find origin selector')
            return []
        }

        // Extract all origin airports from the dropdown
        const originOptions = await page.evaluate((selector: string) => {
            return Array.from(document.querySelectorAll(`${selector} optgroup`)).flatMap(group => {
                const country = group.getAttribute('label') ?? ''
                return Array.from(group.querySelectorAll('option')).map(opt => ({
                    code: (opt as HTMLOptionElement).value,
                    name: opt.textContent?.trim() || '',
                    country
                }))
            })
        }, originSelector)

        // For each origin, select it and extract its destinations
        const airports: Airport[] = []

        for (const airport of originOptions) {
            if (!airport.code) continue

            console.log('Selecting:', airport.code)
            await page.select(originSelector, airport.code)

            try {
                await page.waitForFunction(
                    () => document.querySelectorAll('#destination optgroup > option').length > 0,
                    { timeout: 3000 }
                )
            } catch {
                console.log('No destinations for', airport.code)
                airports.push({ ...airport, destinations: [] })
                continue
            }

            const destinations = await page.evaluate(() => {
                return Array.from(document.querySelectorAll('#destination optgroup > option'))
                    .map(el => el.getAttribute('value'))
                    .filter((v): v is string => v != null)
            })

            airports.push({ ...airport, destinations })
        }

        return airports
    } catch (error) {
        console.error('Airport scrape error:', error)
        return []
    } finally {
        if (browser) await browser.close()
    }
}
