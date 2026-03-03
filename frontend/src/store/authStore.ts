import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  token: string | null;
  username: string | null;
  displayName: string | null;
  roles: string[];
  isAuthenticated: boolean;
  login: (token: string, username: string, displayName: string, roles: string[]) => void;
  logout: () => void;
  hasRole: (role: string) => boolean;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      token: null,
      username: null,
      displayName: null,
      roles: [],
      isAuthenticated: false,
      login: (token, username, displayName, roles) =>
        set({ token, username, displayName, roles, isAuthenticated: true }),
      logout: () =>
        set({ token: null, username: null, displayName: null, roles: [], isAuthenticated: false }),
      hasRole: (role: string) => get().roles.includes(role),
    }),
    { name: 'eras-auth' },
  ),
);
