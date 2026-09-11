import Dexie, { type EntityTable } from 'dexie'
import type { PrayerCategory, PrayerItem, ProgressUpdate } from '../types'

class PrayerDB extends Dexie {
  categories!: EntityTable<PrayerCategory, 'id'>
  items!: EntityTable<PrayerItem, 'id'>
  updates!: EntityTable<ProgressUpdate, 'id'>

  constructor() {
    super('jungbo-prayer-db')
    this.version(1).stores({
      categories: '++id, order',
      items: '++id, categoryId, status, createdAt',
      updates: '++id, itemId, date',
    })
  }
}

export const db = new PrayerDB()

const DEFAULT_CATEGORIES: Omit<PrayerCategory, 'id'>[] = [
  { name: '환우', color: '#e0708a', order: 0 },
  { name: '수험생', color: '#5b8fd6', order: 1 },
  { name: '취업', color: '#5aab8f', order: 2 },
  { name: '결혼', color: '#c98fd6', order: 3 },
  { name: '가정', color: '#d69a5b', order: 4 },
  { name: '기타', color: '#8a8794', order: 5 },
]

export async function ensureSeedData() {
  const count = await db.categories.count()
  if (count === 0) {
    await db.categories.bulkAdd(DEFAULT_CATEGORIES)
  }
}
