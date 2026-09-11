import { Route, Routes } from 'react-router-dom'
import Layout from './components/Layout'
import ItemListPage from './pages/ItemListPage'
import ItemDetailPage from './pages/ItemDetailPage'
import DateViewPage from './pages/DateViewPage'
import CategoryManagePage from './pages/CategoryManagePage'

export default function App() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route index element={<ItemListPage />} />
        <Route path="items/:id" element={<ItemDetailPage />} />
        <Route path="dates" element={<DateViewPage />} />
        <Route path="categories" element={<CategoryManagePage />} />
      </Route>
    </Routes>
  )
}
