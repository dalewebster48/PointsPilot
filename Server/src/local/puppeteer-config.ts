import puppeteer from 'puppeteer-extra'
import StealthPlugin from 'puppeteer-extra-plugin-stealth'
import UserAgent from 'user-agents'

puppeteer.use(StealthPlugin())

export function getPuppeteerConfig() {
    const isProduction = process.env.NODE_ENV === 'production'

    if (isProduction) {
        return {
            headless: true as const,
            executablePath: '/usr/bin/chromium-browser',
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--disable-gpu',
                '--disable-web-security',
                '--disable-features=VizDisplayCompositor',
                '--disable-background-timer-throttling',
                '--disable-backgrounding-occluded-windows',
                '--disable-renderer-backgrounding'
            ],
            defaultViewport: { width: 1280, height: 720 }
        }
    }

    return {
        headless: true as const,
        args: [] as string[]
    }
}

export function getRandomUserAgent(): string {
    return new UserAgent().toString()
}

export { puppeteer }
