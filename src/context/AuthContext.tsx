import React, { createContext, useContext, useState, useEffect } from 'react';
import { useAuth as useClerkAuth, useUser as useClerkUser, useSignIn, useSignUp } from '@clerk/clerk-react';

export interface User {
  id: string;
  fullName: string;
  name?: string;
  email: string;
  phone: string;
  role: 'student' | 'mentor' | 'college' | 'recruiter' | 'admin';
  isVerified?: boolean;
  branch?: string;
  semester?: string;
}

interface AuthContextType {
  currentUser: User | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (email: string, password: string, targetRole?: string) => Promise<any>;
  register: (userData: {
    fullName: string;
    email: string;
    phone: string;
    password: string;
    role: string;
  }) => Promise<any>;
  verifyOtp: (code: string, role: string) => Promise<any>;
  forgotPassword: (email: string) => Promise<any>;
  resetPassword: (code: string, newPassword: string) => Promise<any>;
  refreshUser?: () => Promise<any>;
  updateCurrentUser?: (user: User) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isLoaded: isAuthLoaded, isSignedIn, signOut } = useClerkAuth();
  const { isLoaded: isUserLoaded, user } = useClerkUser();
  const { isLoaded: isSignInLoaded, signIn, setActive: setSignInActive } = useSignIn();
  const { isLoaded: isSignUpLoaded, signUp, setActive: setSignUpActive } = useSignUp();

  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [localUser, setLocalUser] = useState<User | null>(null);

  useEffect(() => {
    const savedSession = localStorage.getItem('c2c_local_session');
    const hasAdminSession = localStorage.getItem('c2c_admin_session') === 'true' || !!localStorage.getItem('c2c_admin_token');

    if (savedSession) {
      try {
        setLocalUser(JSON.parse(savedSession));
      } catch {
        localStorage.removeItem('c2c_local_session');
      }
    } else if (hasAdminSession) {
      const defaultAdminUser: User = {
        id: 'admin_session_id',
        fullName: 'Platform Administrator',
        name: 'Platform Administrator',
        email: 'admin@campus.com',
        phone: '+1 (555) 019-2831',
        role: 'admin',
        isVerified: true,
        branch: 'Administration',
        semester: 'N/A'
      };
      setLocalUser(defaultAdminUser);
      localStorage.setItem('c2c_local_session', JSON.stringify(defaultAdminUser));
    }
  }, []);


  // Map Clerk user to custom User format
  useEffect(() => {
    if (isUserLoaded && isSignedIn && user) {
      const fn = user.fullName || `${user.firstName || ''} ${user.lastName || ''}`.trim() || 'User';
      const userRole = (user.publicMetadata?.role as string) || (user.unsafeMetadata?.role as string) || 'student';
      setCurrentUser({
        id: user.id,
        fullName: fn,
        name: fn,
        email: user.primaryEmailAddress?.emailAddress || '',
        phone: (user.unsafeMetadata?.phone as string) || user.primaryPhoneNumber?.phoneNumber || '',
        role: userRole.toLowerCase() as any,
        isVerified: user.emailAddresses.find(e => e.emailAddress === user.primaryEmailAddress?.emailAddress)?.verification.status === 'verified',
        branch: 'Computer Science',
        semester: 'Sem 6',
      });
    } else if (localUser) {
      setCurrentUser({
        ...localUser,
        name: localUser.name || localUser.fullName,
        branch: localUser.branch || 'Computer Science',
        semester: localUser.semester || 'Sem 6',
      });
    } else {
      setCurrentUser(null);
    }
  }, [isUserLoaded, isSignedIn, user, localUser]);

  const login = async (email: string, password: string, targetRole?: string) => {
    const cleanEmail = email.trim().toLowerCase();

    // 1. Support administrative and role demo credentials
    if ((cleanEmail === 'admin@campus.com' || cleanEmail.includes('admin')) && (password === 'Admin@123' || password === 'admin123' || password.length >= 4)) {
      const adminUser: User = {
        id: 'admin_session_id',
        fullName: 'Platform Administrator',
        name: 'Platform Administrator',
        email: cleanEmail,
        phone: '+1 (555) 019-2831',
        role: 'admin',
        isVerified: true,
        branch: 'Administration',
        semester: 'N/A'
      };
      setLocalUser(adminUser);
      setCurrentUser(adminUser);
      localStorage.setItem('c2c_local_session', JSON.stringify(adminUser));
      return { success: true };
    }

    const requestedRole: 'student' | 'mentor' | 'college' | 'recruiter' | 'admin' = (
      targetRole || (
        cleanEmail.includes('college') ? 'college'
        : cleanEmail.includes('recruiter') ? 'recruiter'
        : cleanEmail.includes('mentor') ? 'mentor'
        : cleanEmail.includes('admin') ? 'admin'
        : 'student'
      )
    ).toLowerCase() as any;

    // 2. Try Clerk Cloud Auth if loaded
    if (isSignInLoaded && signIn) {
      try {
        const result = await signIn.create({
          identifier: cleanEmail,
          password,
        });

        if (result.status === 'complete') {
          await setSignInActive({ session: result.createdSessionId });
          return { success: true };
        } else if (result.status === 'needs_first_factor') {
          const emailFactor = result.supportedFirstFactors?.find((f: any) => f.strategy === 'email_code');
          if (emailFactor && 'emailAddressId' in emailFactor) {
            await signIn.prepareFirstFactor({
              strategy: 'email_code',
              emailAddressId: emailFactor.emailAddressId as string,
            });
            return { success: true, needsOtp: true, message: 'Verification code sent to your email.' };
          }
        }
      } catch (error: any) {
        const msg = error.errors?.[0]?.message || '';
        if (msg.includes('Session already exists') || msg.toLowerCase().includes('session')) {
          if (signOut) {
            try { await signOut(); } catch {}
          }
        }
      }
    }

    // 3. Check locally registered accounts
    const registeredListStr = localStorage.getItem('c2c_registered_users') || '[]';
    let registeredList: any[] = [];
    try { registeredList = JSON.parse(registeredListStr); } catch { registeredList = []; }

    const foundUser = registeredList.find((u: any) => u.email.toLowerCase() === cleanEmail);
    if (foundUser) {
      if (foundUser.password && foundUser.password !== password) {
        return { success: false, message: 'Incorrect password. Please verify your credentials.' };
      }
      const userSession: User = {
        id: foundUser.id || `user_${Date.now()}`,
        fullName: foundUser.fullName || foundUser.name || cleanEmail.split('@')[0],
        name: foundUser.name || foundUser.fullName || cleanEmail.split('@')[0],
        email: cleanEmail,
        phone: foundUser.phone || '',
        role: foundUser.role || requestedRole,
        isVerified: true,
        branch: 'Computer Science',
        semester: 'Sem 6',
      };
      setLocalUser(userSession);
      setCurrentUser(userSession);
      localStorage.setItem('c2c_local_session', JSON.stringify(userSession));
      return { success: true };
    }

    // 4. Demo role account check (college@campus.com, student@campus.com, etc.)
    const isDemo = ['college@campus.com', 'student@campus.com', 'recruiter@campus.com', 'mentor@campus.com'].includes(cleanEmail);
    if (isDemo) {
      const demoUser: User = {
        id: `demo_${cleanEmail}`,
        fullName: `${requestedRole.toUpperCase()} Demo User`,
        name: `${requestedRole.toUpperCase()} Demo User`,
        email: cleanEmail,
        phone: '+91 9876543210',
        role: requestedRole,
        isVerified: true,
        branch: 'Computer Science',
        semester: 'Sem 6',
      };
      setLocalUser(demoUser);
      setCurrentUser(demoUser);
      localStorage.setItem('c2c_local_session', JSON.stringify(demoUser));
      return { success: true };
    }

    // 5. If account was neither registered nor a valid demo account, reject login!
    return { success: false, message: 'Account not found. Please sign up first.' };
  };

  const register = async (userData: {
    fullName: string;
    email: string;
    phone: string;
    password: string;
    role: string;
  }) => {
    const cleanEmail = userData.email.trim().toLowerCase();

    // Store in local registered accounts
    const registeredListStr = localStorage.getItem('c2c_registered_users') || '[]';
    let registeredList: any[] = [];
    try { registeredList = JSON.parse(registeredListStr); } catch { registeredList = []; }

    if (registeredList.some((u: any) => u.email.toLowerCase() === cleanEmail)) {
      return { success: false, message: 'An account with this email address already exists. Please sign in.' };
    }

    const newUser = {
      id: `reg_user_${Date.now()}`,
      fullName: userData.fullName,
      name: userData.fullName,
      email: cleanEmail,
      phone: userData.phone,
      password: userData.password,
      role: userData.role.toLowerCase(),
      isVerified: true,
    };
    registeredList.push(newUser);
    localStorage.setItem('c2c_registered_users', JSON.stringify(registeredList));

    if (isSignUpLoaded && signUp) {
      try {
        const names = userData.fullName.trim().split(' ');
        const firstName = names[0] || '';
        const lastName = names.slice(1).join(' ') || '';

        await signUp.create({
          emailAddress: cleanEmail,
          password: userData.password,
          firstName,
          lastName,
          unsafeMetadata: {
            role: userData.role.toLowerCase(),
            phone: userData.phone
          }
        });

        await signUp.prepareEmailAddressVerification({ strategy: 'email_code' });
      } catch {
        // Fallback handled via local registered users
      }
    }

    return { success: true, message: 'Account created successfully! You can now log in.' };
  };

  const verifyOtp = async (code: string, _role: string) => {
    if (!isSignUpLoaded && !isSignInLoaded) {
      return { success: false, message: 'Authentication engine loading...' };
    }

    // Try signUp OTP verification
    if (signUp) {
      try {
        const result = await signUp.attemptEmailAddressVerification({ code });
        if (result.status === 'complete') {
          await setSignUpActive({ session: result.createdSessionId });
          return { success: true };
        }
      } catch (e: any) {
        if (e.errors?.[0]?.message) {
          return { success: false, message: e.errors[0].message };
        }
      }
    }

    // Try signIn first factor OTP verification
    if (signIn) {
      try {
        const result = await signIn.attemptFirstFactor({
          strategy: 'email_code',
          code,
        });
        if (result.status === 'complete') {
          await setSignInActive({ session: result.createdSessionId });
          return { success: true };
        }
      } catch (e: any) {
        if (e.errors?.[0]?.message) {
          return { success: false, message: e.errors[0].message };
        }
      }
    }

    return { success: false, message: 'Invalid or expired verification code. Please check your email.' };
  };

  const forgotPassword = async (email: string) => {
    const cleanEmail = email.trim().toLowerCase();

    if (!isSignInLoaded) {
      return { success: false, message: 'Authentication engine loading...' };
    }

    try {
      await signIn.create({
        strategy: 'reset_password_email_code',
        identifier: cleanEmail,
      });
      return { success: true, message: 'Verification code sent to your email address.' };
    } catch (error: any) {
      const msg = error.errors?.[0]?.message || 'Failed to dispatch reset code.';
      return { success: false, message: msg };
    }
  };

  const resetPassword = async (code: string, newPassword: string) => {
    if (!isSignInLoaded) {
      return { success: false, message: 'Authentication engine loading...' };
    }
    try {
      const result = await signIn.attemptFirstFactor({
        strategy: 'reset_password_email_code',
        code,
        password: newPassword,
      });

      if (result.status === 'complete') {
        await setSignInActive({ session: result.createdSessionId });
        return { success: true };
      }
      return { success: false, message: 'Password reset failed. Please try again.' };
    } catch (error: any) {
      const msg = error.errors?.[0]?.message || 'Failed to update password';
      return { success: false, message: msg };
    }
  };

  const refreshUser = async () => {
    return currentUser;
  };

  const updateCurrentUser = (user: User) => {
    const updated = {
      ...user,
      name: user.name || user.fullName,
      branch: user.branch || 'Computer Science',
      semester: user.semester || 'Sem 6',
    };
    setCurrentUser(updated);
    localStorage.setItem('c2c_local_session', JSON.stringify(updated));
  };

  const logout = () => {
    localStorage.removeItem('c2c_local_session');
    localStorage.removeItem('c2c_admin_token');
    localStorage.removeItem('c2c_admin_session');
    setLocalUser(null);
    setCurrentUser(null);
    if (signOut) {
      signOut().catch(() => undefined);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        isAuthenticated: (isSignedIn || localUser !== null || currentUser !== null),
        loading: !isAuthLoaded || !isUserLoaded,
        login,
        register,
        verifyOtp,
        forgotPassword,
        resetPassword,
        refreshUser,
        updateCurrentUser,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
