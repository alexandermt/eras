import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import styles from './Layout.module.css';

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const { displayName, roles, logout } = useAuthStore();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className={styles.shell}>
      <header className={styles.header}>
        <div className={styles.brand}>
          <span className={styles.brandLogo}>ERAS</span>
          <span className={styles.brandText}>Enterprise Ranking &amp; Admissions</span>
        </div>
        <nav className={styles.nav}>
          <Link to="/" className={styles.navLink}>Workspaces</Link>
          <Link to="/applicants" className={styles.navLink}>Applicants</Link>
        </nav>
        <div className={styles.user}>
          <span className={styles.userName}>{displayName}</span>
          {roles.map((r) => (
            <span key={r} className={styles.badge}>{r}</span>
          ))}
          <button onClick={handleLogout} className={styles.logoutBtn}>Sign Out</button>
        </div>
      </header>
      <main className={styles.main}>{children}</main>
    </div>
  );
}
