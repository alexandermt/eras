import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './store/authStore';
import Layout from './components/Layout';
import LoginPage from './pages/LoginPage';
import WorkspacesPage from './pages/WorkspacesPage';
import WorkspaceDetailPage from './pages/WorkspaceDetailPage';
import ApplicantsPage from './pages/ApplicantsPage';

function RequireAuth({ children }: { children: JSX.Element }) {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  return children;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/"
          element={
            <RequireAuth>
              <Layout>
                <WorkspacesPage />
              </Layout>
            </RequireAuth>
          }
        />
        <Route
          path="/workspaces/:id"
          element={
            <RequireAuth>
              <Layout>
                <WorkspaceDetailPage />
              </Layout>
            </RequireAuth>
          }
        />
        <Route
          path="/applicants"
          element={
            <RequireAuth>
              <Layout>
                <ApplicantsPage />
              </Layout>
            </RequireAuth>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
