import { SortOrder } from './types'

type Condition = {
    column: string
    op: '=' | 'LIKE' | '>=' | '<=' | '>' | '<' | 'IN'
    value: any
}

type QueryOptions = {
    conditions: Condition[]
    orderBy?: { column: string; direction: SortOrder }
    limit?: number
    offset?: number
    /** When sorting by a cost column, exclude zero-value rows */
    excludeZeroOnSort?: boolean
}

export function buildWhere(conditions: Condition[]): { clause: string; params: any[] } {
    if (conditions.length === 0) return { clause: '', params: [] }

    const parts: string[] = []
    const params: any[] = []

    for (const c of conditions) {
        if (c.op === 'IN') {
            const values = c.value as any[]
            const placeholders = values.map(() => '?').join(', ')
            parts.push(`${c.column} IN (${placeholders})`)
            params.push(...values)
        } else if (c.op === 'LIKE') {
            parts.push(`${c.column} LIKE ?`)
            params.push(`%${c.value}%`)
        } else {
            parts.push(`${c.column} ${c.op} ?`)
            params.push(c.value)
        }
    }

    return { clause: 'WHERE ' + parts.join(' AND '), params }
}

export function buildOrderBy(column: string, direction: SortOrder): string {
    return `ORDER BY ${column} ${direction === 'desc' ? 'DESC' : 'ASC'}`
}

export function buildPagination(limit: number, offset: number): { clause: string; params: [number, number] } {
    return { clause: 'LIMIT ? OFFSET ?', params: [limit, offset] }
}

/**
 * Helper to collect conditions from a filter object using a field mapping.
 * Each mapping entry maps a filter key to { column, op }.
 */
export function conditionsFromFilter<T extends Record<string, any>>(
    filter: T | undefined,
    mapping: { key: keyof T; column: string; op: Condition['op'] }[]
): Condition[] {
    if (!filter) return []

    const conditions: Condition[] = []
    for (const m of mapping) {
        const value = filter[m.key]
        if (value != null) {
            if (Array.isArray(value)) {
                if (value.length > 0) {
                    conditions.push({ column: m.column, op: 'IN', value })
                }
            } else {
                conditions.push({ column: m.column, op: m.op, value })
            }
        }
    }
    return conditions
}
