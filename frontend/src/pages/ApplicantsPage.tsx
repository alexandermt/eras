import React, { useEffect, useState } from 'react';
import { listApplicants } from '../services/erasApi';
import type { Applicant } from '../types';
import styles from './ApplicantsPage.module.css';

export default function ApplicantsPage() {
  const [applicants, setApplicants] = useState<Applicant[]>([]);
  const [loading, setLoading] = useState(true);
  const [program, setProgram] = useState('');
  const [cycleYear, setCycleYear] = useState('');
  const [error, setError] = useState('');

  const load = async () => {
    setLoading(true);
    setError('');
    try {
      const data = await listApplicants(program || undefined, cycleYear ? Number(cycleYear) : undefined);
      setApplicants(data);
    } catch {
      setError('Failed to load applicants (Oracle ITS may be unavailable)');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleFilter = (e: React.FormEvent) => {
    e.preventDefault();
    load();
  };

  return (
    <div>
      <div className={styles.pageHeader}>
        <h2>Applicants</h2>
        <span className={styles.badge}>Read-only · Oracle ITS</span>
      </div>

      <form onSubmit={handleFilter} className={styles.filterRow}>
        <input
          placeholder="Program"
          value={program}
          onChange={(e) => setProgram(e.target.value)}
          className={styles.input}
        />
        <input
          placeholder="Cycle Year"
          type="number"
          value={cycleYear}
          onChange={(e) => setCycleYear(e.target.value)}
          className={styles.input}
        />
        <button type="submit" className={styles.filterBtn}>Filter</button>
      </form>

      {error && <p className={styles.error}>{error}</p>}

      {loading ? (
        <p className={styles.loading}>Loading applicants…</p>
      ) : (
        <table className={styles.table}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Last Name</th>
              <th>First Name</th>
              <th>Program</th>
              <th>Status</th>
              <th>GPA</th>
              <th>Step 1</th>
              <th>Step 2</th>
              <th>Email</th>
            </tr>
          </thead>
          <tbody>
            {applicants.map((a) => (
              <tr key={a.applicant_id}>
                <td>{a.applicant_id}</td>
                <td>{a.last_name}</td>
                <td>{a.first_name}</td>
                <td>{a.program ?? '—'}</td>
                <td>{a.status ?? '—'}</td>
                <td>{a.gpa ?? '—'}</td>
                <td>{a.usmle_step1 ?? '—'}</td>
                <td>{a.usmle_step2 ?? '—'}</td>
                <td>{a.email ?? '—'}</td>
              </tr>
            ))}
            {applicants.length === 0 && (
              <tr>
                <td colSpan={9} className={styles.empty}>No applicants found.</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
