import { Flight } from '../../shared/types'
import { puppeteer, getPuppeteerConfig, getRandomUserAgent } from '../puppeteer-config'

export async function scrapeFlights(
    originCode: string,
    destinationCode: string,
    month: string,
    year: number
): Promise<Flight[]> {
    const url = `https://www.virginatlantic.com/reward-flight-finder/results/month?origin=${originCode}&destination=${destinationCode}&month=${month}&year=${year}`
    let browser

    try {
        browser = await puppeteer.launch(getPuppeteerConfig())
        const page = await browser.newPage()

        // Block heavy resources
        await page.setRequestInterception(true)
        page.on('request', req => {
            const rt = req.resourceType()
            const reqUrl = req.url()

            if (['image', 'stylesheet', 'font', 'media'].includes(rt)) {
                return req.abort()
            }
            if (/doubleclick|google-analytics|googlesyndication|adsystem|analytics|track/.test(reqUrl)) {
                return req.abort()
            }
            return req.continue()
        })

        page.setDefaultNavigationTimeout(20000)
        page.setDefaultTimeout(10000)

        await page.setUserAgent(getRandomUserAgent())
        await page.setViewport({
            width: 1080 + Math.floor(Math.random() * 100),
            height: 1024 + Math.floor(Math.random() * 100)
        })

        await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 20000 })
        await page.waitForSelector('article[data-cy="availability-card"]', { timeout: 15000 })

        const flights = await page.evaluate((
            selector: string,
            origin: string,
            dest: string,
            m: string,
            y: number
        ) => {
            const createDate = (dayStr: string, month: string, year: number): string => {
                const day = parseInt(dayStr.match(/\d+/)?.[0] || '1', 10)
                const date = new Date(year, parseInt(month) - 1, day)
                const yyyy = date.getFullYear()
                const mm = String(date.getMonth() + 1).padStart(2, '0')
                const dd = String(date.getDate()).padStart(2, '0')
                return `${yyyy}-${mm}-${dd}`
            }

            const getPoints = (article: Element, dataCy: string): number | null => {
                const div = article.querySelector(`div[data-cy="${dataCy}"]`)
                const spans = div?.querySelectorAll('span')
                const text = spans && spans.length >= 2 ? spans[1].textContent?.trim() : null
                if (!text?.includes('pts')) return null
                const num = parseInt(text.replace(/[,pts ]/g, ''))
                return isNaN(num) ? null : num
            }

            const hasDeal = (article: Element, dataCy: string): boolean => {
                const div = article.querySelector(`div[data-cy="${dataCy}"]`)
                return div?.querySelector("span[data-cy='saver-tag-icon']") != null
            }

            return Array.from(document.querySelectorAll(selector))
                .map(article => {
                    const dateText = article.querySelector('h2')?.textContent?.trim() || ''
                    const economy = getPoints(article, 'economy')
                    const premium = getPoints(article, 'premium')
                    const upper = getPoints(article, 'upper-class')

                    if (!economy && !premium && !upper) return null

                    return {
                        date: createDate(dateText, m, y),
                        origin,
                        destination: dest,
                        economyCost: economy ?? 0,
                        economyDeal: hasDeal(article, 'economy'),
                        premiumCost: premium ?? 0,
                        premiumDeal: hasDeal(article, 'premium'),
                        upperCost: upper ?? 0,
                        upperDeal: hasDeal(article, 'upper-class')
                    }
                })
                .filter(f => f != null)
        }, 'article[data-cy="availability-card"]', originCode, destinationCode, month, year)

        return flights as Flight[]
    } catch (error) {
        console.error(`Error scraping flights ${originCode}->${destinationCode} ${month}/${year}:`, error)
        return []
    } finally {
        if (browser) await browser.close()
    }
}
