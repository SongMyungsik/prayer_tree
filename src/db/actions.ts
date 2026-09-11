import { db } from './db'
import type { PrayerCategory, PrayerItem, PrayerStatus, ProgressUpdate } from '../types'

function nowIso() {
  return new Date().toISOString()
}

export async function createCategory(name: string, color: string) {
  const maxOrder = await db.categories.orderBy('order').last()
  return db.categories.add({ name, color, order: (maxOrder?.order ?? -1) + 1 })
}

export async function updateCategory(id: number, changes: Partial<Pick<PrayerCategory, 'name' | 'color'>>) {
  return db.categories.update(id, changes)
}

export async function deleteCategory(id: number) {
  const itemIds = (await db.items.where('categoryId').equals(id).primaryKeys()) as number[]
  await db.updates.where('itemId').anyOf(itemIds).delete()
  await db.items.where('categoryId').equals(id).delete()
  return db.categories.delete(id)
}

export async function createPrayerItem(input: {
  categoryId: number
  title: string
  personName?: string
  description?: string
}) {
  const timestamp = nowIso()
  const item: Omit<PrayerItem, 'id'> = {
    categoryId: input.categoryId,
    title: input.title,
    personName: input.personName,
    description: input.description,
    status: 'praying',
    createdAt: timestamp,
    updatedAt: timestamp,
  }
  return db.items.add(item)
}

export async function updatePrayerItem(
  id: number,
  changes: Partial<Pick<PrayerItem, 'title' | 'personName' | 'description' | 'categoryId'>>,
) {
  return db.items.update(id, { ...changes, updatedAt: nowIso() })
}

export async function setPrayerItemStatus(id: number, status: PrayerStatus) {
  return db.items.update(id, { status, updatedAt: nowIso() })
}

export async function deletePrayerItem(id: number) {
  await db.updates.where('itemId').equals(id).delete()
  return db.items.delete(id)
}

export async function addProgressUpdate(itemId: number, date: string, content: string) {
  const update: Omit<ProgressUpdate, 'id'> = {
    itemId,
    date,
    content,
    createdAt: nowIso(),
  }
  await db.items.update(itemId, { updatedAt: nowIso() })
  return db.updates.add(update)
}

export async function deleteProgressUpdate(id: number) {
  return db.updates.delete(id)
}
