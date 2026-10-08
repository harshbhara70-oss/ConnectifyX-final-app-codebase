// Global type definitions
export interface User {
  id: string;
  name: string;
  email: string;
  role: 'student' | 'recruiter' | 'college' | 'mentor' | 'admin';
}
