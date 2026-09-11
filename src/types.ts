export type PrayerStatus = 'praying' | 'answered' | 'paused'

export const STATUS_LABEL: Record<PrayerStatus, string> = {
  praying: '기도 중',
  answered: '응답됨',
  paused: '보류',
}

export interface PrayerCategory {
  id?: number
  name: string
  color: string
  order: number
}

export interface PrayerItem {
  id?: number
  categoryId: number
  title: string
  personName?: string
  description?: string
  status: PrayerStatus
  createdAt: string
  updatedAt: string
}

export interface ProgressUpdate {
  id?: number
  itemId: number
  date: string
  content: string
  createdAt: string
}
