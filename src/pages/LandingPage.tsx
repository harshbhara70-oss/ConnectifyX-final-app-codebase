import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  Briefcase,
  GraduationCap,
  Users,
  UserCheck,
  Brain,
  Calendar,
  Cpu,
  Award,
  BookOpen,
  ArrowRight,
  ChevronRight,
  FileText,
  Check,
  BarChart3,
  Database,
  MessageSquare,
  Building,
  Target,
  Sparkles,
  Zap,
  Mic,
  Globe,
} from 'lucide-react';

// Custom Reusable Brand Logo component representing Campus2Corporate
const LogoSVG: React.FC<{ className?: string; iconColor?: string; textColor?: string }> = ({
  className = "h-8 w-auto",
  iconColor = "text-[#5e17eb]",
  textColor = "text-slate-900"
}) => {
  return (
    <svg className={className} viewBox="0 0 140 40" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="4" y="6" width="28" height="28" rx="8" className={`fill-purple-50/60 stroke-current ${iconColor}`} strokeWidth="2" />
      <path d="M12 24C12 18.4772 16.4772 14 22 14" className={`stroke-current ${iconColor}`} strokeWidth="3" strokeLinecap="round" />
      <path d="M24 16C24 21.5228 19.5228 26 14 26" className={`stroke-current ${iconColor}`} strokeWidth="3" strokeLinecap="round" />
      <text x="42" y="26" className={`fill-current ${textColor}`} fontSize="19" fontWeight="800" letterSpacing="-0.04em">C2C</text>
    </svg>
  );
};

// Inline SVG replacement for Linkedin icon since the project's outdated lucide-react package does not export it
const Linkedin: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z" />
    <rect x="2" y="9" width="4" height="12" />
    <circle cx="4" cy="4" r="2" />
  </svg>
);

// Inline SVG replacement for Twitter icon since the project's outdated lucide-react package does not export it
const Twitter: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z" />
  </svg>
);

// Reusable Scroll Reveal component using IntersectionObserver
const ScrollReveal: React.FC<{ children: React.ReactNode; className?: string; id?: string }> = ({ children, className = "", id }) => {
  const [isVisible, setIsVisible] = useState(false);
  const domRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const currentDom = domRef.current;
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(true);
            if (currentDom) observer.unobserve(currentDom);
          }
        });
      },
      { threshold: 0.05 }
    );

    if (currentDom) {
      observer.observe(currentDom);
    }

    return () => {
      if (currentDom) {
        observer.unobserve(currentDom);
      }
    };
  }, []);

  return (
    <div
      ref={domRef}
      id={id}
      className={`transition-all duration-1000 ease-out transform ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        } ${className}`}
    >
      {children}
    </div>
  );
};

// Removed HERO_PHRASES

// ─── Inline Icon SVG Helpers for Authentication Onboarding Flow ────────────
const CloseIcon: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
    <line x1="18" y1="6" x2="6" y2="18" />
    <line x1="6" y1="6" x2="18" y2="18" />
  </svg>
);



const EyeIcon: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
    <circle cx="12" cy="12" r="3" />
  </svg>
);

const EyeOffIcon: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
    <line x1="1" y1="1" x2="23" y2="23" />
  </svg>
);

const ChevronLeftIcon: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M15 18l-6-6 6-6" />
  </svg>
);

const ShieldCheckIcon: React.FC<{ className?: string }> = ({ className = "w-4 h-4" }) => (
  <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
    <path d="m9 11 2 2 4-4" />
  </svg>
);

export const LandingPage: React.FC = () => {
  const navigate = useNavigate();

  const phrases = [
    "Power Campus Placements",
    "Build Industry-Ready-Talent",
    "Accelerate Enterprise Hiring"
  ];

  const [hoveredStakeholder, setHoveredStakeholder] = useState<string | null>(null);

  // Onboarding authentication states
  const [showAuthFlow, setShowAuthFlow] = useState(false);
  const [authScreen, setAuthScreen] = useState<'none' | 'select' | 'signup' | 'login' | 'forgot' | 'otp' | 'reset' | 'admin-login'>('select');
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [activeStakeholder, setActiveStakeholder] = useState<string | null>(null);
  const stakeholderContainerRef = useRef<HTMLDivElement>(null);
  const [activeFaq, setActiveFaq] = useState<number | null>(null);
  const [selectedRole, setSelectedRole] = useState<'Student' | 'Mentor' | 'College' | 'Recruiter'>('Student');
  const [showPassword, setShowPassword] = useState(false);

  // Auth Context hooks
  const { login, register, verifyOtp, forgotPassword, resetPassword, isAuthenticated, logout, currentUser, updateCurrentUser } = useAuth();

  // Signup fields state
  const [regFullName, setRegFullName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPhone, setRegPhone] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regTerms, setRegTerms] = useState(false);

  // Login fields state
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');

  // Forgot password & Reset states
  const [forgotEmail, setForgotEmail] = useState('');
  const [otpDigits, setOtpDigits] = useState<string[]>(['', '', '', '', '', '']);
  const [otpTimer, setOtpTimer] = useState(59);
  const [otpTimerActive, setOtpTimerActive] = useState(false);
  const [otpPurpose, setOtpPurpose] = useState<'signup' | 'login' | 'reset'>('signup');
  const [resetOtpCode, setResetOtpCode] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmNewPassword, setConfirmNewPassword] = useState('');
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  // Field validation error states
  const [regFullNameError, setRegFullNameError] = useState('');
  const [regEmailError, setRegEmailError] = useState('');
  const [regPhoneError, setRegPhoneError] = useState('');
  const [regPasswordError, setRegPasswordError] = useState('');
  const [loginEmailError, setLoginEmailError] = useState('');
  const [loginPasswordError, setLoginPasswordError] = useState('');
  const [forgotEmailError, setForgotEmailError] = useState('');
  const [newPasswordError, setNewPasswordError] = useState('');
  const [confirmNewPasswordError, setConfirmNewPasswordError] = useState('');

  // Status and loading states
  const [formLoading, setFormLoading] = useState(false);
  const [formError, setFormError] = useState('');
  const [formSuccess, setFormSuccess] = useState('');

  // OTP Countdown Timer
  useEffect(() => {
    let interval: ReturnType<typeof setInterval> | null = null;
    if (otpTimerActive && otpTimer > 0) {
      interval = setInterval(() => {
        setOtpTimer((prev) => prev - 1);
      }, 1000);
    } else if (otpTimer === 0) {
      setOtpTimerActive(false);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [otpTimerActive, otpTimer]);

  // Global Click-Outside Event Reset for Stakeholder Accordion Cards
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (stakeholderContainerRef.current && !stakeholderContainerRef.current.contains(event.target as Node)) {
        setActiveStakeholder(null);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  // Clear errors and successes on tab or modal shifts
  useEffect(() => {
    setFormError('');
    setFormSuccess('');
    setRegFullNameError('');
    setRegEmailError('');
    setRegPhoneError('');
    setRegPasswordError('');
    setLoginEmailError('');
    setLoginPasswordError('');
    setForgotEmailError('');
    setNewPasswordError('');
    setConfirmNewPasswordError('');
  }, [authScreen, selectedRole, showAuthFlow]);

  // Handle redirects based on role
  const redirectUserByRole = (role: string) => {
    switch (role.toLowerCase()) {
      case 'student':
        navigate('/student-dashboard');
        break;
      case 'mentor':
        navigate('/mentor-dashboard');
        break;
      case 'college':
        navigate('/college-dashboard');
        break;
      case 'recruiter':
        navigate('/recruiter-dashboard');
        break;
      case 'admin':
        navigate('/admin-dashboard');
        break;
      default:
        navigate('/');
    }
  };



  const handleAdminLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    setFormSuccess('');
    setLoginEmailError('');
    setLoginPasswordError('');

    let hasErrors = false;
    if (!loginEmail) {
      setLoginEmailError('Email is required');
      hasErrors = true;
    }
    if (!loginPassword) {
      setLoginPasswordError('Password is required');
      hasErrors = true;
    }

    if (hasErrors) return;

    setFormLoading(true);
    try {
      const result = await login(loginEmail, loginPassword);
      setFormLoading(false);

      if (result.success) {
        const savedSessionStr = localStorage.getItem('c2c_local_session');
        let sessionRole = '';
        if (savedSessionStr) {
          try {
            sessionRole = JSON.parse(savedSessionStr).role || '';
          } catch {
            sessionRole = '';
          }
        }
        const effectiveRole = (sessionRole || currentUser?.role || '').toLowerCase();

        if (effectiveRole === 'admin' || loginEmail.toLowerCase().includes('admin')) {
          if (effectiveRole !== 'admin' && currentUser) {
            updateCurrentUser?.({
              ...currentUser,
              role: 'admin',
            });
          }
          setFormSuccess('Administrative credentials verified. Redirecting to control portal...');
          setTimeout(() => {
            setShowAuthFlow(false);
            navigate('/admin/dashboard');
          }, 800);
        } else {
          setFormError('Access Denied: Administrative credentials required.');
        }
      } else {
        setFormError(result.message || 'Access Denied: Administrative credentials required.');
      }
    } catch (err: any) {
      setFormLoading(false);
      setFormError('Access Denied: Administrative credentials required.');
    }
  };

  // Client-side validations
  const validateEmail = (email: string, _role: string) => {
    if (!email) {
      return 'Email address is required';
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email.trim())) {
      return 'Please enter a valid email address.';
    }
    return '';
  };

  const validatePassword = (password: string) => {
    if (!password) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    const hasUpperCase = /[A-Z]/.test(password);
    const hasNumber = /\d/.test(password);
    const hasSpecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
    if (!hasUpperCase || !hasNumber || !hasSpecial) {
      return 'Must contain an uppercase letter, a number, and a special character';
    }
    return '';
  };

  const handleSignupSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    setFormSuccess('');
    setRegFullNameError('');
    setRegEmailError('');
    setRegPhoneError('');
    setRegPasswordError('');

    let hasErrors = false;

    if (!regFullName) {
      setRegFullNameError('Full Name is required');
      hasErrors = true;
    }

    const emailErr = validateEmail(regEmail, selectedRole);
    if (emailErr) {
      setRegEmailError(emailErr);
      if (emailErr.includes('required') || emailErr.includes('valid')) {
        hasErrors = true;
      }
    }

    if (!regPhone) {
      setRegPhoneError('Phone Number is required');
      hasErrors = true;
    } else if (regPhone.trim().length < 10) {
      setRegPhoneError('Please enter a valid phone number (minimum 10 digits)');
      hasErrors = true;
    }

    const passErr = validatePassword(regPassword);
    if (passErr) {
      setRegPasswordError(passErr);
      hasErrors = true;
    }

    if (!regTerms) {
      setFormError('You must agree to the Terms of Service & Privacy Policy');
      hasErrors = true;
    }

    if (hasErrors) {
      return;
    }

    setFormLoading(true);
    const result = await register({
      fullName: regFullName,
      email: regEmail,
      phone: regPhone,
      password: regPassword,
      role: selectedRole.toLowerCase()
    });
    setFormLoading(false);

    if (result.success) {
      setFormSuccess(result.message || 'Verification code dispatched to your email address.');
      setOtpTimer(59);
      setOtpTimerActive(true);
      setOtpPurpose('signup');
      setAuthScreen('otp');
    } else {
      setFormError(result.message || 'Registration failed');
    }
  };

  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    setFormSuccess('');
    setLoginEmailError('');
    setLoginPasswordError('');

    let hasErrors = false;

    if (!loginEmail) {
      setLoginEmailError('Email is required');
      hasErrors = true;
    } else {
      const emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
      if (!emailRegex.test(loginEmail)) {
        setLoginEmailError('Please enter a valid email address');
        hasErrors = true;
      }
    }

    if (!loginPassword) {
      setLoginPasswordError('Password is required');
      hasErrors = true;
    }

    if (hasErrors) {
      return;
    }

    setFormLoading(true);
    const result = await login(loginEmail, loginPassword, selectedRole.toLowerCase());
    setFormLoading(false);

    if (result.success) {
      if (result.needsOtp) {
        setFormSuccess(result.message || 'Verification code dispatched to your email address.');
        setOtpTimer(59);
        setOtpTimerActive(true);
        setOtpPurpose('login');
        setAuthScreen('otp');
      } else {
        setFormSuccess('Signed in successfully! Redirecting...');
        setLoginEmail('');
        setLoginPassword('');
        setTimeout(() => {
          setShowAuthFlow(false);
          redirectUserByRole(currentUser?.role || selectedRole.toLowerCase());
        }, 1200);
      }
    } else {
      setFormError(result.message || 'Invalid email or password');
    }
  };

  const handleForgotSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setForgotEmailError('');
    setFormError('');
    setFormSuccess('');

    const emailErr = validateEmail(forgotEmail, selectedRole);
    if (emailErr) {
      setForgotEmailError(emailErr);
      if (emailErr.includes('required') || emailErr.includes('valid')) {
        return;
      }
    }

    setFormLoading(true);
    const result = await forgotPassword(forgotEmail);
    setFormLoading(false);

    if (result.success) {
      setFormSuccess('Verification code sent to your email.');
      setOtpTimer(59);
      setOtpTimerActive(true);
      setOtpPurpose('reset');
      setAuthScreen('otp');
    } else {
      setFormError(result.message || 'Failed to dispatch reset code.');
    }
  };

  const handleOtpChange = (index: number, value: string) => {
    if (value && !/^\d$/.test(value)) return;

    const newOtp = [...otpDigits];
    newOtp[index] = value;
    setOtpDigits(newOtp);

    if (value && index < 5) {
      const nextInput = document.getElementById(`otp-input-${index + 1}`) as HTMLInputElement;
      if (nextInput) nextInput.focus();
    }
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace') {
      const newOtp = [...otpDigits];
      if (!newOtp[index] && index > 0) {
        newOtp[index - 1] = '';
        setOtpDigits(newOtp);
        const prevInput = document.getElementById(`otp-input-${index - 1}`) as HTMLInputElement;
        if (prevInput) prevInput.focus();
      } else {
        newOtp[index] = '';
        setOtpDigits(newOtp);
      }
    }
  };

  const handleOtpVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    setFormSuccess('');

    const otpCode = otpDigits.join('');
    if (otpCode.length < 6) {
      setFormError('Please enter all 6 digits of the confirmation code.');
      return;
    }

    setFormLoading(true);
    if (otpPurpose === 'signup' || otpPurpose === 'login') {
      const result = await verifyOtp(otpCode, selectedRole.toLowerCase());
      setFormLoading(false);
      if (result.success) {
        setFormSuccess('Verification successful! Redirecting to dashboard...');
        setRegFullName('');
        setRegEmail('');
        setRegPhone('');
        setRegPassword('');
        setRegTerms(false);
        setTimeout(() => {
          setShowAuthFlow(false);
          redirectUserByRole(currentUser?.role || selectedRole.toLowerCase());
        }, 1200);
      } else {
        setFormError(result.message || 'Invalid OTP code provided. Please try again.');
      }
    } else {
      // Save code for password reset and advance screen
      setFormLoading(false);
      setResetOtpCode(otpCode);
      setFormSuccess('Verification code confirmed. Please set your new password.');
      setAuthScreen('reset');
    }
  };

  const handleResendCode = async () => {
    setFormError('');
    setFormSuccess('');
    setFormLoading(true);
    let result;
    if (otpPurpose === 'signup') {
      // Re-trigger registration email dispatch
      result = await register({
        fullName: regFullName,
        email: regEmail,
        phone: regPhone,
        password: regPassword,
        role: selectedRole.toLowerCase()
      });
    } else {
      result = await forgotPassword(forgotEmail);
    }
    setFormLoading(false);

    if (result.success) {
      setOtpTimer(59);
      setOtpTimerActive(true);
      setFormSuccess('A new verification code has been dispatched.');
    } else {
      setFormError(result.message || 'Failed to dispatch code.');
    }
  };

  const handleResetSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    setFormSuccess('');
    setNewPasswordError('');
    setConfirmNewPasswordError('');

    let hasErrors = false;

    const passErr = validatePassword(newPassword);
    if (passErr) {
      setNewPasswordError(passErr);
      hasErrors = true;
    }

    if (!confirmNewPassword) {
      setConfirmNewPasswordError('Please confirm your new password');
      hasErrors = true;
    } else if (newPassword !== confirmNewPassword) {
      setConfirmNewPasswordError('Passwords do not match');
      hasErrors = true;
    }

    if (hasErrors) {
      return;
    }

    setFormLoading(true);
    const result = await resetPassword(resetOtpCode, newPassword);
    setFormLoading(false);

    if (result.success) {
      setFormSuccess('Password updated successfully! Redirecting to your dashboard...');
      setNewPassword('');
      setConfirmNewPassword('');
      setTimeout(() => {
        setShowAuthFlow(false);
        redirectUserByRole(currentUser?.role || selectedRole.toLowerCase());
      }, 1200);
    } else {
      setFormError(result.message || 'Failed to reset password.');
    }
  };

  // Hero phrase rotation state
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [isPhraseTransitioning, setIsPhraseTransitioning] = useState(false);



  useEffect(() => {
    let phraseTimeoutId: ReturnType<typeof setTimeout> | null = null;

    const phraseInterval = setInterval(() => {
      setIsPhraseTransitioning(true);
      phraseTimeoutId = setTimeout(() => {
        setPhraseIndex((prev) => (prev + 1) % phrases.length);
        setIsPhraseTransitioning(false);
      }, 300);
    }, 2000);

    return () => {
      clearInterval(phraseInterval);
      if (phraseTimeoutId) clearTimeout(phraseTimeoutId);
    };
  }, [phrases.length]);

  const stakeholders = [
    { 
      id: 'student', 
      name: 'Candidates', 
      desc: 'Build verified portfolios, develop in-demand skills, and connect with the right career opportunities through AI-powered guidance.', 
      color: 'from-blue-500 to-cyan-400',
      features: ['Verified Digital Portfolio', 'Personalized Learning Paths', 'AI Job Recommendations', 'Placement Readiness Score'],
      kpi: { value: '25K+', label: 'Active Students' }
    },
    { 
      id: 'college', 
      name: 'Institutions', 
      desc: 'Track student readiness, automate placement operations, and gain real-time insights across every batch.', 
      color: 'from-purple-500 to-indigo-400',
      features: ['Placement Analytics Dashboard', 'Batch Performance Tracking', 'Placement Drive Management', 'Outcome & Accreditation Reports'],
      kpi: { value: '100+', label: 'Partner Institutions' }
    },
    { 
      id: 'mentor', 
      name: 'Advisors', 
      desc: 'Guide students with structured mentorship, mock interviews, and career readiness programs.', 
      color: 'from-pink-500 to-rose-400',
      features: ['1-on-1 Mentorship', 'Resume & Portfolio Reviews', 'Mock Interviews', 'Career Readiness Certification'],
      kpi: { value: '500+', label: 'Industry Mentors' }
    },
    { 
      id: 'recruiter', 
      name: 'Talent Acquisition', 
      desc: 'Discover verified candidates, reduce screening time, and hire through AI-powered matching.', 
      color: 'from-emerald-500 to-teal-400',
      features: ['AI Candidate Matching', 'Verified Skill Profiles', 'Interview Scheduling', 'Recruitment Dashboard'],
      kpi: { value: '92%', label: 'Matching Accuracy' }
    },
    { 
      id: 'company', 
      name: 'Enterprise Partners', 
      desc: 'Build scalable campus hiring pipelines with verified graduates and workforce-ready talent.', 
      color: 'from-amber-500 to-orange-400',
      features: ['Campus Hiring Programs', 'Talent Pipeline Management', 'Bulk Recruitment', 'Hiring Analytics'],
      kpi: { value: '500+', label: 'Hiring Partners' }
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#F7F5FF] via-white to-[#F0ECFF] text-slate-800 font-sans selection:bg-purple-100 selection:text-purple-900 overflow-x-hidden relative">

      {/* Background decoration elements (Delicate Dot Matrix Canvas & Glowing Lights) */}
      <div className="absolute top-0 left-0 right-0 h-[800px] pointer-events-none overflow-hidden z-0 bg-[radial-gradient(#e9d5ff_1px,transparent_1px)] [background-size:20px_20px] opacity-70">
        <div className="absolute top-[-15%] left-[10%] w-[700px] h-[700px] rounded-full bg-purple-100/40 blur-[130px]"></div>
        <div className="absolute top-[20%] right-[5%] w-[600px] h-[600px] rounded-full bg-indigo-100/40 blur-[120px]"></div>
      </div>

      {/* Header / Navbar */}
      <header className="relative z-50 border-b border-purple-100/70 bg-white/80 backdrop-blur-md sticky top-0 shadow-sm transition-all duration-300">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <LogoSVG iconColor="text-[#5e17eb]" textColor="text-slate-900" />
            <div className="hidden md:block border-l border-purple-100 pl-4">
              <span className="text-[10px] block text-slate-400 uppercase tracking-widest font-bold leading-none">Ashoksoft</span>
              <span className="text-[10px] block text-slate-400 uppercase tracking-widest font-bold leading-none mt-1">Technologies</span>
            </div>
          </div>

          <nav className="hidden lg:flex items-center space-x-8 text-sm font-semibold text-slate-600">
            <a href="#problem" className="hover:text-[#5e17eb] transition-colors py-2 relative after:absolute after:bottom-0 after:left-0 after:w-0 after:h-0.5 after:bg-[#5e17eb] hover:after:w-full after:transition-all after:duration-300">
              Problem
            </a>

            <a href="#solution" className="hover:text-[#5e17eb] transition-colors py-2 relative after:absolute after:bottom-0 after:left-0 after:w-0 after:h-0.5 after:bg-[#5e17eb] hover:after:w-full after:transition-all after:duration-300">
              Solution
            </a>

            {/* Core Features Dropdown */}
            <div className="relative group">
              <button className="hover:text-[#5e17eb] transition-colors flex items-center gap-1.5 py-2 cursor-pointer">
                Core Features
                <ChevronRight className="w-3.5 h-3.5 rotate-90 text-slate-400 group-hover:text-[#5e17eb] transition-transform duration-200" />
              </button>

              <div className="absolute top-full left-0 mt-1 w-64 bg-white/95 backdrop-blur-md border border-purple-100 rounded-2xl shadow-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 z-50 py-2">
                <a href="#features" className="block px-4 py-2.5 text-xs text-slate-700 hover:bg-purple-50/60 hover:text-[#5e17eb] transition-colors font-medium">Resume Analyzer</a>
                <a href="#features" className="block px-4 py-2.5 text-xs text-slate-700 hover:bg-purple-50/60 hover:text-[#5e17eb] transition-colors font-medium">AI Mock Interviews</a>
                <a href="#features" className="block px-4 py-2.5 text-xs text-slate-700 hover:bg-purple-50/60 hover:text-[#5e17eb] transition-colors font-medium">Skill Assessments</a>
                <a href="#features" className="block px-4 py-2.5 text-xs text-slate-700 hover:bg-purple-50/60 hover:text-[#5e17eb] transition-colors font-medium">Placement Monitoring</a>
                <a href="#features" className="block px-4 py-2.5 text-xs text-slate-700 hover:bg-purple-50/60 hover:text-[#5e17eb] transition-colors font-medium">Learning Roadmaps</a>
              </div>
            </div>

            <a href="#ecosystem" className="hover:text-[#5e17eb] transition-colors py-2 relative after:absolute after:bottom-0 after:left-0 after:w-0 after:h-0.5 after:bg-[#5e17eb] hover:after:w-full after:transition-all after:duration-300">
              Ecosystem
            </a>

            <a href="#how-it-works" className="hover:text-[#5e17eb] transition-colors py-2 relative after:absolute after:bottom-0 after:left-0 after:w-0 after:h-0.5 after:bg-[#5e17eb] hover:after:w-full after:transition-all after:duration-300">
              AI Engine
            </a>
          </nav>

          <div className="flex items-center space-x-3">
            {isAuthenticated ? (
              <div className="hidden lg:flex items-center space-x-3">
                <button
                  onClick={() => redirectUserByRole(currentUser?.role || 'student')}
                  className="inline-flex items-center justify-center px-4.5 py-2 border border-purple-200 bg-white hover:bg-purple-50/50 hover:border-purple-300 rounded-xl text-xs font-semibold text-slate-750 transition-all cursor-pointer shadow-sm"
                >
                  Go to Dashboard
                </button>
                <button
                  onClick={logout}
                  className="inline-flex items-center justify-center px-5 py-2 bg-red-600 hover:bg-red-700 text-xs font-bold text-white rounded-xl shadow-sm transition-all cursor-pointer"
                >
                  Sign Out
                </button>
              </div>
            ) : (
              <div className="hidden lg:flex items-center space-x-3">
                <button 
                  onClick={() => {
                    setShowAuthFlow(true);
                    setAuthScreen('select');
                  }}
                  className="inline-flex items-center justify-center px-4.5 py-2 border border-purple-200 bg-white hover:bg-purple-50/50 hover:border-purple-300 rounded-xl text-xs font-semibold text-slate-750 transition-all cursor-pointer shadow-sm"
                >
                  Login
                </button>
                <button
                  onClick={() => {
                    setShowAuthFlow(true);
                    setAuthScreen('select');
                  }}
                  className="inline-flex items-center justify-center px-5 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-xs font-bold text-white rounded-xl shadow-sm shadow-purple-500/20 transition-all cursor-pointer"
                >
                  Get Started
                </button>
              </div>
            )}

            {/* Hamburger Mobile Menu Toggle Button */}
            <button
              onClick={() => setShowMobileMenu(!showMobileMenu)}
              className="lg:hidden p-2.5 rounded-xl border border-purple-100 hover:bg-purple-50/50 text-slate-600 transition-all cursor-pointer z-50"
              aria-label="Toggle mobile menu"
            >
              {showMobileMenu ? <CloseIcon className="w-4 h-4" /> : (
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                </svg>
              )}
            </button>
          </div>
        </div>
      </header>

      {/* 1. Hero Section */}
      <section className="relative overflow-hidden z-10 pt-16 pb-24 md:pt-20 md:pb-32 w-full bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-tr from-indigo-50/40 via-white to-purple-50/40">

        {/* Background Accents */}
        <div className="absolute top-[-10%] left-[-15%] w-[1000px] h-[1000px] bg-[#5e17eb]/10 rounded-full blur-[140px] pointer-events-none" />
        <div className="absolute bottom-[-10%] right-[-15%] w-[800px] h-[800px] bg-[#5e17eb]/5 rounded-full blur-[120px] pointer-events-none" />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">

            {/* Left Column (Text Content) */}
            <div className="lg:col-span-6 flex flex-col space-y-8 text-center lg:text-left items-center lg:items-start relative z-20">
              <div className="inline-flex items-center space-x-2 px-3.5 py-1.5 rounded-full bg-purple-50/80 border border-purple-100 text-xs font-bold text-purple-700 shadow-sm backdrop-blur-sm transition-all duration-300">
                <LogoSVG className="h-4 w-auto" iconColor="text-[#5e17eb]" textColor="text-slate-900" />
                <span className="border-l border-purple-200 pl-2 uppercase tracking-wider text-[9px]">Enterprise Career Development Ecosystem</span>
              </div>

              <h1 className="text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-extrabold tracking-tighter text-slate-900 leading-[1.1] max-w-2xl">
                From Learning to Hiring —
              </h1>

              <div className="h-12 overflow-hidden relative mt-2 w-full flex items-center justify-center lg:justify-start">
                <span
                  className={`inline-block text-xl sm:text-2xl md:text-3xl bg-gradient-to-r from-purple-600 to-indigo-600 bg-clip-text text-transparent font-extrabold ${
                    isPhraseTransitioning
                      ? 'opacity-0 translate-y-2 scale-95 transition-all duration-300 ease-out'
                      : 'opacity-100 translate-y-0 scale-100 transition-all duration-300 ease-out'
                  }`}
                >
                  {phrases[phraseIndex]}
                </span>
              </div>

              <p className="text-lg text-slate-500 leading-relaxed max-w-xl font-medium">
                Empower students with structured courses, real-world projects, AI-powered assessments, expert mentorship, and data-driven career guidance—while enabling institutions to track performance and recruiters to discover enterprise-ready talent.
              </p>

              <div className="flex flex-col sm:flex-row gap-4 pt-2 w-full sm:w-auto">
                <button
                  onClick={() => {
                    setShowAuthFlow(true);
                    setAuthScreen('select');
                  }}
                  className="group inline-flex items-center justify-center px-8 py-3.5 rounded-xl bg-[#5e17eb] hover:bg-[#4b12bc] text-base font-semibold text-white shadow-lg hover:shadow-purple-500/30 active:scale-[0.98] transition-all duration-300 transform hover:scale-[1.01] cursor-pointer"
                >
                  Initiate Integration
                  <ArrowRight className="ml-2 w-5 h-5 group-hover:translate-x-1 transition-transform duration-300" />
                </button>
                <a
                  href="#solution"
                  className="inline-flex items-center justify-center px-8 py-3.5 rounded-xl bg-white border border-slate-200 hover:border-slate-300 text-base font-semibold text-slate-700 hover:bg-slate-50 hover:shadow-md hover:-translate-y-0.5 transition-all duration-300 shadow-sm"
                >
                  Review Institutional Solutions
                </a>
              </div>
            </div>

            {/* Right Column (Image & Floating Badges) */}
            <div className="lg:col-span-6 relative flex justify-center lg:justify-end mt-12 lg:mt-0">
              {/* The main student image */}
              <div className="relative z-10 w-full max-w-[500px]">
                <img
                  src="/Images/student_hero_image.png"
                  alt="Student ready for corporate placement"
                  className="w-full h-auto object-cover rounded-full shadow-2xl shadow-purple-500/20 relative z-10 aspect-square"
                />

                {/* College Building faint overlay behind student */}
                <img
                  src="/Images/college-building.png"
                  alt=""
                  className="absolute bottom-0 left-[-20%] w-[120%] opacity-10 object-contain -z-10 pointer-events-none"
                />

                {/* Floating Badge: Learn */}
                <div className="absolute top-[8%] left-[0%] sm:left-[5%] bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] rounded-2xl p-3 flex flex-col items-center justify-center z-20 hover:-translate-y-1 transition-transform duration-300">
                  <div className="w-10 h-10 bg-purple-100 text-[#5e17eb] rounded-xl flex items-center justify-center mb-1">
                    <GraduationCap className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-700">Learn</span>
                </div>

                {/* Floating Badge: Build */}
                <div className="absolute top-[45%] left-[-12%] sm:left-[-8%] bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] rounded-2xl p-3 flex flex-col items-center justify-center hover:-translate-y-1 transition-transform duration-300 z-20">
                  <div className="w-10 h-10 bg-purple-100 text-[#5e17eb] rounded-xl flex items-center justify-center mb-1">
                    <Cpu className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-700">Build</span>
                </div>

                {/* Floating Badge: Assess */}
                <div className="absolute bottom-[15%] left-[-2%] sm:left-[5%] bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] rounded-2xl p-3 flex flex-col items-center justify-center hover:-translate-y-1 transition-transform duration-300 z-20">
                  <div className="w-10 h-10 bg-purple-100 text-[#5e17eb] rounded-xl flex items-center justify-center mb-1">
                    <FileText className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-700">Assess</span>
                </div>

                {/* Floating Badge: Career Growth */}
                <div className="absolute top-[12%] right-[0%] sm:right-[5%] bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] rounded-2xl p-3 flex flex-col items-center justify-center hover:-translate-y-1 transition-transform duration-300 z-20">
                  <div className="w-10 h-10 bg-purple-100 text-[#5e17eb] rounded-xl flex items-center justify-center mb-1">
                    <BarChart3 className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-700 text-center leading-tight">Career<br />Growth</span>
                </div>

                {/* Floating Badge: Top Recruiters */}
                <div className="absolute top-[45%] right-[-12%] sm:right-[-8%] bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] rounded-2xl p-3 flex flex-col items-center justify-center hover:-translate-y-1 transition-transform duration-300 z-20">
                  <div className="w-10 h-10 bg-purple-100 text-[#5e17eb] rounded-xl flex items-center justify-center mb-1">
                    <Briefcase className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-700 text-center leading-tight">Top<br />Recruiters</span>
                </div>

                {/* Floating Badge: Right Opportunities */}
                <div className="absolute bottom-[20%] right-[-5%] sm:right-[2%] bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.04)] rounded-2xl p-3 flex flex-col items-center justify-center hover:-translate-y-1 transition-transform duration-300 z-20">
                  <div className="w-10 h-10 bg-purple-100 text-[#5e17eb] rounded-xl flex items-center justify-center mb-1">
                    <Target className="w-5 h-5" />
                  </div>
                  <span className="text-[10px] font-bold text-slate-700 text-center leading-tight">Right<br />Opportunities</span>
                </div>

                {/* Floating Badge: Placement Success */}
                <div className="absolute bottom-[5%] right-[10%] sm:right-[15%] bg-white/95 backdrop-blur-md p-4 rounded-2xl shadow-2xl shadow-purple-500/15 border border-white flex items-center gap-3 z-30 hover:-translate-y-1 transition-transform duration-300">
                  <div className="w-10 h-10 bg-[#5e17eb] text-white rounded-xl flex items-center justify-center">
                    <Sparkles className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Placement Success</span>
                    <div className="flex items-end gap-2">
                      <span className="text-2xl font-black text-[#5e17eb] leading-none">92%</span>
                      {/* SVG Chart sparkline */}
                      <svg width="40" height="20" viewBox="0 0 40 20" fill="none" className="opacity-80">
                        <path d="M2 18L12 10L20 14L38 2" stroke="#5e17eb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                        <path d="M38 2V6M38 2H34" stroke="#5e17eb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    </div>
                  </div>
                </div>

              </div>
            </div>
          </div>

          {/* Bottom Stats Bar */}
          <div className="mt-20 relative z-20">
            <div className="bg-white/90 backdrop-blur-md rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-slate-100 p-6 sm:p-8 flex flex-wrap justify-between items-center gap-6 lg:gap-4 max-w-5xl mx-auto hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-shadow duration-300">
              {/* Stat 1 */}
              <div className="flex items-center gap-4 w-full sm:w-[45%] lg:w-auto">
                <div className="w-12 h-12 bg-purple-50 text-[#5e17eb] rounded-xl flex items-center justify-center shrink-0">
                  <Building className="w-6 h-6" />
                </div>
                <div>
                  <span className="block text-sm font-extrabold text-slate-900">Trusted by 500+</span>
                  <span className="block text-xs font-semibold text-slate-500">Institutions</span>
                </div>
              </div>

              {/* Stat 2 */}
              <div className="flex items-center gap-4 w-full sm:w-[45%] lg:w-auto">
                <div className="w-12 h-12 bg-purple-50 text-[#5e17eb] rounded-xl flex items-center justify-center shrink-0">
                  <Users className="w-6 h-6" />
                </div>
                <div>
                  <span className="block text-sm font-extrabold text-slate-900">10K+ Students</span>
                  <span className="block text-xs font-semibold text-slate-500">Empowered</span>
                </div>
              </div>

              {/* Stat 3 */}
              <div className="flex items-center gap-4 w-full sm:w-[45%] lg:w-auto">
                <div className="w-12 h-12 bg-purple-50 text-[#5e17eb] rounded-xl flex items-center justify-center shrink-0">
                  <Briefcase className="w-6 h-6" />
                </div>
                <div>
                  <span className="block text-sm font-extrabold text-slate-900">50+ Corporate</span>
                  <span className="block text-xs font-semibold text-slate-500">Partners</span>
                </div>
              </div>

              {/* Stat 4 */}
              <div className="flex items-center gap-4 w-full sm:w-[45%] lg:w-auto">
                <div className="w-12 h-12 bg-purple-50 text-[#5e17eb] rounded-xl flex items-center justify-center shrink-0">
                  <Sparkles className="w-6 h-6" />
                </div>
                <div>
                  <span className="block text-sm font-extrabold text-slate-900">AI-Driven</span>
                  <span className="block text-xs font-semibold text-slate-500">Matching</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      {/* ================= Placement Impact ================= */}

      {/* ================= Placement Intelligence ================= */}

      <ScrollReveal className="relative z-10 py-24 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

          {/* Heading */}

          <div className="text-center max-w-3xl mx-auto mb-16">

            <span className="inline-flex items-center px-4 py-2 rounded-full bg-violet-50 border border-violet-100 text-violet-700 text-xs font-bold tracking-widest uppercase">

              Placement Intelligence

            </span>

            <h2 className="mt-5 text-4xl font-extrabold tracking-tight text-slate-900">

              Real Outcomes. Measurable Impact.

            </h2>

            <p className="mt-4 text-slate-500 text-lg leading-relaxed">

              AI continuously measures student readiness, hiring success,
              recruiter engagement, and placement outcomes across the ecosystem.

            </p>

          </div>

          {/* Main Card */}

          <div className="rounded-[32px] border border-slate-200 bg-white shadow-xl overflow-hidden">

            {/* Top */}

            <div className="flex flex-col lg:flex-row">

              {/* Left */}

              <div className="lg:w-2/3 p-10 border-b lg:border-b-0 lg:border-r border-slate-200">

                <div className="flex items-center justify-between mb-8">

                  <div>

                    <h3 className="text-xl font-bold text-slate-900">

                      Placement Performance

                    </h3>

                    <p className="text-sm text-slate-500 mt-1">

                      Last updated 2 minutes ago

                    </p>

                  </div>

                  <span className="px-3 py-1 rounded-full bg-green-50 text-green-700 text-xs font-bold">

                    ↑ 12.8% Growth

                  </span>

                </div>

                {/* Fake Graph */}

                <div className="h-52 relative">

                  <svg
                    className="absolute inset-0 w-full h-full"
                    viewBox="0 0 800 250"
                    fill="none"
                  >

                    <defs>

                      <linearGradient id="lineGradient" x1="0" x2="1">

                        <stop offset="0%" stopColor="#5e17eb"/>

                        <stop offset="100%" stopColor="#8b5cf6"/>

                      </linearGradient>

                    </defs>

                    <path

                      d="M0 180
                      C80 160,
                      150 120,
                      230 135
                      S380 80,
                      470 95
                      S650 35,
                      800 45"

                      stroke="url(#lineGradient)"

                      strokeWidth="6"

                      fill="none"

                      strokeLinecap="round"

                    />

                  </svg>

                </div>

              </div>

              {/* Right */}

              <div className="lg:w-1/3 grid grid-cols-2">

                {[
                  {
                    value: "95%",
                    label: "Placement Success",
                  },
                  {
                    value: "4,280+",
                    label: "Students Placed",
                  },
                  {
                    value: "620+",
                    label: "Hiring Partners",
                  },
                  {
                    value: "₹18.6L",
                    label: "Highest Package",
                  },
                ].map((item) => (

                  <div
                    key={item.label}
                    className="border-b border-r border-slate-200 last:border-b-0 even:border-r-0 p-8 hover:bg-violet-50/40 transition-all duration-300"
                  >

                    <div className="text-4xl font-black text-slate-900">

                      {item.value}

                    </div>

                    <div className="mt-2 text-sm text-slate-500 leading-relaxed">

                      {item.label}

                    </div>

                  </div>

                ))}

              </div>

            </div>

            {/* Bottom */}

            <div className="grid grid-cols-1 md:grid-cols-3 border-t border-slate-200">

              <div className="p-8">

                <p className="text-xs uppercase tracking-widest text-slate-400 font-bold">

                  AI Matching Accuracy

                </p>

                <h3 className="mt-3 text-3xl font-black text-violet-700">

                  92%

                </h3>

              </div>

              <div className="p-8 border-y md:border-y-0 md:border-x border-slate-200">

                <p className="text-xs uppercase tracking-widest text-slate-400 font-bold">

                  Average Hiring Time

                </p>

                <h3 className="mt-3 text-3xl font-black text-violet-700">

                  5 Days

                </h3>

              </div>

              <div className="p-8">

                <p className="text-xs uppercase tracking-widest text-slate-400 font-bold">

                  Recruiter Satisfaction

                </p>

                <h3 className="mt-3 text-3xl font-black text-violet-700">

                  4.9/5

                </h3>

              </div>

            </div>

          </div>

        </div>
      </ScrollReveal>
      
      
      {/* 2. Trusted Value Section */}
      <ScrollReveal className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <h2 className="text-xs font-bold text-[#5e17eb] uppercase tracking-widest">PLACEMENT ECOSYSTEM</h2>
            <p className="text-3xl sm:text-4xl font-extrabold text-slate-900 mt-3 tracking-tight">The Complete Placement Ecosystem</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">

            {/* Student Card */}
            <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300 group">
              <div className="w-11 h-11 rounded-xl bg-indigo-50 flex items-center justify-center text-indigo-600 mb-5 group-hover:bg-indigo-650 group-hover:text-white group-hover:scale-110 transition-all duration-300 shadow-sm">
                <GraduationCap className="w-5.5 h-5.5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">{stakeholders[0].name}</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                {stakeholders[0].desc}
              </p>
            </div>

            {/* College Card */}
            <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300 group">
              <div className="w-11 h-11 rounded-xl bg-violet-50 flex items-center justify-center text-violet-600 mb-5 group-hover:bg-violet-600 group-hover:text-white group-hover:scale-110 transition-all duration-300 shadow-sm">
                <Building className="w-5.5 h-5.5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">{stakeholders[1].name}</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                {stakeholders[1].desc}
              </p>
            </div>

            {/* Recruiter Card */}
            <div className="bg-white/85 backdrop-blur-md border-2 border-[#5e17eb]/80 shadow-[0_8px_30px_rgb(94,23,235,0.06)] rounded-3xl p-6 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.08)] transition-all duration-300 group scale-105 relative z-10">
              <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-gradient-to-r from-[#5e17eb] to-purple-600 text-white text-[10px] font-bold px-3 py-1 rounded-full shadow-md uppercase tracking-widest border border-white/20 whitespace-nowrap">
                AI Powered
              </span>
              <div className="w-11 h-11 rounded-xl bg-[#5e17eb] flex items-center justify-center text-white mb-5 group-hover:scale-110 transition-all duration-300 shadow-sm">
                <Briefcase className="w-5.5 h-5.5" />
              </div>
              <h3 className="text-base font-bold text-[#5e17eb] mb-2">{stakeholders[3].name}</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                {stakeholders[3].desc}
              </p>
            </div>

            {/* Mentor Card */}
            <div 
              onClick={() => navigate('/mentor-dashboard')}
              className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300 group cursor-pointer"
            >
              <div className="w-11 h-11 rounded-xl bg-fuchsia-50 flex items-center justify-center text-fuchsia-600 mb-5 group-hover:bg-fuchsia-650 group-hover:text-white group-hover:scale-110 transition-all duration-300 shadow-sm">
                <Users className="w-5.5 h-5.5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">{stakeholders[2].name}</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                {stakeholders[2].desc}
              </p>
            </div>

            {/* Company Card */}
            <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300 group">
              <div className="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center text-purple-650 mb-5 group-hover:bg-purple-600 group-hover:text-white group-hover:scale-110 transition-all duration-300 shadow-sm">
                <Target className="w-5.5 h-5.5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2">{stakeholders[4].name}</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                {stakeholders[4].desc}
              </p>
            </div>

          </div>

          {/* AI Core Foundation Banner */}
          <div className="mt-16 w-full bg-gradient-to-r from-[#5e17eb] via-[#4b12bc] to-[#5e17eb] rounded-3xl p-1 shadow-2xl shadow-[#5e17eb]/20 relative overflow-hidden group hover:scale-[1.01] transition-transform duration-500">
            <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImEiIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTTAgMTBoNDBNMTAgMHY0ME0yMCAwaDBNMzAgMHY0ME0wIDIwaDQwTTAgMzBoNDAiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLW9wYWNpdHk9IjAuMSIgZmlsbD0ibm9uZSIvPjwvcGF0dGVybj48L2RlZnM+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0idXJsKCNhKSIvPjwvc3ZnPg==')] opacity-20"></div>
            <div className="bg-white/10 backdrop-blur-md w-full h-full rounded-[23px] p-8 md:p-10 flex flex-col md:flex-row items-center justify-between border border-white/20">
              <div className="flex-1 pr-0 md:pr-10 text-center md:text-left mb-8 md:mb-0">
                <div className="inline-flex items-center space-x-2 bg-white/20 backdrop-blur-md rounded-full px-4 py-1.5 mb-5 border border-white/30 shadow-sm">
                  <Sparkles className="w-4 h-4 text-white" />
                  <span className="text-[10px] font-bold text-white uppercase tracking-widest">Cognitive Core Engine</span>
                </div>
                <h3 className="text-2xl md:text-3xl font-extrabold text-white mb-3">The AI Engine Powering Every Hiring Decision</h3>
                <p className="text-purple-100 text-sm font-medium leading-relaxed max-w-2xl mx-auto md:mx-0 mb-6">
                  Our proprietary neural matching engine processes millions of data points from students, colleges, and enterprises in real-time—eliminating manual sourcing and ensuring perfect-fit placements.
                </p>
                <div className="flex flex-col sm:flex-row items-center justify-center md:justify-start gap-4 sm:gap-8">
                  {['AI Matching', 'Skill Gap Detection', 'Placement Prediction'].map((feature, i) => (
                    <div key={i} className="flex items-center space-x-2.5">
                      <div className="w-5 h-5 rounded-full bg-white/20 flex items-center justify-center">
                        <Check className="w-3 h-3 text-white" />
                      </div>
                      <span className="text-white text-sm font-bold tracking-wide">{feature}</span>
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Animated Core Graphic */}
              <div className="w-32 h-32 md:w-40 md:h-40 relative flex items-center justify-center shrink-0">
                <div className="absolute inset-0 bg-white/20 rounded-full blur-xl animate-pulse"></div>
                <div className="absolute inset-4 border border-white/40 rounded-full animate-[spin_10s_linear_infinite]"></div>
                <div className="absolute inset-8 border-2 border-dashed border-white/40 rounded-full animate-[spin_15s_linear_infinite_reverse]"></div>
                <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center shadow-[0_0_40px_rgba(255,255,255,0.8)] z-10 relative">
                  <Cpu className="w-8 h-8 text-[#5e17eb]" />
                  <div className="absolute inset-0 bg-[#5e17eb]/20 rounded-full animate-ping"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </ScrollReveal>

      {/* 3. Problem Section */}
      <ScrollReveal id="problem" className="relative z-10 py-20 md:py-28 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 rounded-3xl shadow-sm">
        {/* Ambient Background Bloom */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-[#5e17eb]/5 rounded-full blur-[120px] pointer-events-none"></div>

        <div className="relative z-10 text-center max-w-3xl mx-auto mb-20">
          <span className="px-3.5 py-1.5 rounded-full bg-[#5e17eb]/10 border border-[#5e17eb]/20 text-xs font-bold text-[#5e17eb] shadow-sm tracking-wider">
            THE PROBLEM WE SOLVE
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight leading-tight">
            Why Traditional Placement Systems No Longer Work
          </h2>
          <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
            Fragmented workflows, outdated assessments, and limited visibility prevent institutions from delivering enterprise-ready talent at scale.
          </p>
        </div>

        <div className="relative z-10 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">

          {/* Problem 1 */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 relative overflow-hidden group hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            <div className="absolute top-0 right-0 w-36 h-36 bg-[#5e17eb]/5 rounded-full blur-xl pointer-events-none group-hover:bg-[#5e17eb]/10 transition-all duration-500"></div>
            <div className="text-[#5e17eb] text-xs font-mono font-black tracking-widest mb-4">01 / LOWER PLACEMENT SUCCESS</div>
            <h3 className="text-lg font-bold text-slate-900 mb-2.5">Industry-Academia Disconnect</h3>
            <p className="text-xs text-slate-500 leading-relaxed font-medium">
              Academic learning often fails to align with evolving industry expectations, leaving graduates underprepared for real-world roles.
            </p>
          </div>

          {/* Problem 2 */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 relative overflow-hidden group hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            <div className="absolute top-0 right-0 w-36 h-36 bg-[#5e17eb]/5 rounded-full blur-xl pointer-events-none group-hover:bg-[#5e17eb]/10 transition-all duration-500"></div>
            <div className="text-[#5e17eb] text-xs font-mono font-black tracking-widest mb-4">02 / POOR DECISION MAKING</div>
            <h3 className="text-lg font-bold text-slate-900 mb-2.5">Limited Performance Insights</h3>
            <p className="text-xs text-slate-500 leading-relaxed font-medium">
              Institutions lack real-time analytics to monitor readiness, identify skill gaps, and improve placement performance.
            </p>
          </div>

          {/* Problem 3 */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 relative overflow-hidden group hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            <div className="absolute top-0 right-0 w-36 h-36 bg-[#5e17eb]/5 rounded-full blur-xl pointer-events-none group-hover:bg-[#5e17eb]/10 transition-all duration-500"></div>
            <div className="text-[#5e17eb] text-xs font-mono font-black tracking-widest mb-4">03 / SLOWER HIRING PROCESS</div>
            <h3 className="text-lg font-bold text-slate-900 mb-2.5">Unverified Student Profiles</h3>
            <p className="text-xs text-slate-500 leading-relaxed font-medium">
              Recruiters spend valuable time reviewing resumes without verified projects, assessments, or validated technical skills.
            </p>
          </div>

          {/* Problem 4 */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 relative overflow-hidden group hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            <div className="absolute top-0 right-0 w-36 h-36 bg-[#5e17eb]/5 rounded-full blur-xl pointer-events-none group-hover:bg-[#5e17eb]/10 transition-all duration-500"></div>
            <div className="text-[#5e17eb] text-xs font-mono font-black tracking-widest mb-4">04 / HIGHER TRAINING COSTS</div>
            <h3 className="text-lg font-bold text-slate-900 mb-2.5">Extended Onboarding Cycles</h3>
            <p className="text-xs text-slate-500 leading-relaxed font-medium">
              Hiring candidates without validated skills increases onboarding time, training costs, and productivity delays.
            </p>
          </div>
        </div>
      </ScrollReveal>

        {/* 4. Solution Section */}
      <ScrollReveal id="solution" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 overflow-hidden">
        {/* Ambient Background Bloom */}
        <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-[#5e17eb]/5 rounded-full blur-[100px] pointer-events-none -translate-y-1/2 translate-x-1/3"></div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="text-center max-w-3xl mx-auto mb-20">
            <span className="px-3.5 py-1.5 rounded-full bg-[#5e17eb]/10 border border-[#5e17eb]/20 text-xs font-bold text-[#5e17eb] shadow-sm uppercase tracking-wider">
              AI PLACEMENT PIPELINE
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight leading-tight">
              One Intelligent Journey. From Learning to Hiring.
            </h2>
            <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
              Every stage of the student journey—from skill development to enterprise hiring—is connected through one AI-powered platform.
            </p>
          </div>

          {/* Solution Path Flow */}
          <div className="relative">
            {/* Connection line in background */}
            <div className="hidden lg:block absolute top-[44px] left-[5%] right-[5%] h-0.5 bg-slate-200/80"></div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-7 gap-6">

              {[
                { stage: 'PROFILE', title: 'Verified Portfolios', desc: 'Secure, validated credential trails.', icon: UserCheck },
                { stage: 'ASSESS', title: 'Skill Assessments', desc: 'Proctored technical assessments.', icon: Brain },
                { stage: 'LEARN', title: 'Personalized Learning', desc: 'Targeted skill paths bridging gap logs.', icon: BookOpen },
                { stage: 'MENTOR', title: 'Mentorship', desc: 'Structured mock assessments.', icon: Users },
                { stage: 'MATCH', title: 'AI Job Matching', desc: 'Semantic matching to active roles.', icon: Cpu },
                { stage: 'INTERVIEW', title: 'Interview Management', desc: 'Coordinated scheduling & pipelines.', icon: Calendar },
                { stage: 'PLACE', title: 'Successful Placement', desc: 'Onboarding validation & metrics.', icon: Award }
              ].map((item, idx, arr) => {
                const isAI = item.title === 'AI Job Matching';
                return (
                  <div key={idx} className={`relative flex flex-col items-center text-center ${isAI ? 'bg-white/85 backdrop-blur-md border-2 border-[#5e17eb] shadow-[0_12px_40px_rgb(94,23,235,0.08)] scale-105 z-20 hover:-translate-y-1.5' : 'bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] z-10'} rounded-3xl p-5 transition-all duration-300 group h-full`}>
                    
                    {/* Arrow connecting to next card (visible only on lg+ screens) */}
                    {idx < arr.length - 1 && (
                      <div className="hidden lg:flex absolute top-[44px] -right-[16px] w-6 h-6 items-center justify-center text-slate-300 z-0 -translate-y-1/2">
                        <ChevronRight className="w-5 h-5" />
                      </div>
                    )}
                    
                    {isAI && (
                      <span className="absolute -top-2.5 bg-gradient-to-r from-[#5e17eb] to-purple-600 text-white text-[9px] font-bold px-3 py-1 rounded-full shadow-md uppercase tracking-widest border border-white/20 whitespace-nowrap">
                        AI Powered
                      </span>
                    )}
                    
                    <div className={`w-12 h-12 rounded-full flex items-center justify-center shadow-sm relative z-10 transition-all duration-300 group-hover:scale-110 ${isAI ? 'bg-[#5e17eb] text-white border-none' : 'bg-[#5e17eb]/5 border border-slate-200 text-[#5e17eb] group-hover:bg-[#5e17eb] group-hover:border-[#5e17eb] group-hover:text-white'}`}>
                      <item.icon className="w-5 h-5" />
                    </div>
                    
                    {/* Stage Label */}
                    <span className="text-[9px] font-bold text-[#5e17eb] uppercase tracking-widest mt-4 mb-1">
                      {item.stage}
                    </span>
                    
                    <h3 className={`text-xs font-bold tracking-tight ${isAI ? 'text-[#5e17eb]' : 'text-slate-800'}`}>{item.title}</h3>
                    <p className="text-[10px] text-slate-500 mt-2.5 leading-relaxed font-medium">
                      {item.desc}
                    </p>
                  </div>
                );
              })}

            </div>
          </div>
        </div>
      </ScrollReveal>

      {/* 5. Core Features Section (Asymmetric Bento Grid Layout) */}
      <ScrollReveal id="features" className="relative z-10 py-20 md:py-28 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 opacity-95 rounded-3xl shadow-sm">
        {/* Ambient Background Bloom */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[1000px] h-[1000px] bg-[#5e17eb]/5 rounded-full blur-[150px] pointer-events-none z-[-1]"></div>

        <div className="text-center max-w-3xl mx-auto mb-20 relative z-10">
          <span className="px-3.5 py-1.5 rounded-full bg-[#5e17eb]/10 border border-[#5e17eb]/20 text-xs font-bold text-[#5e17eb] shadow-sm uppercase tracking-wider">
            PLATFORM CAPABILITIES
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight">
            A Complete Platform for Campus-to-Corporate Success
          </h2>
          <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
            Manage learning, assessments, mentorship, recruitment, and placement through one unified ecosystem.
          </p>
        </div>

        {/* Bento Grid layout */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8">

          {/* Card 1 - ATS Analysis (Span 2) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 lg:p-8 group flex flex-col justify-between min-h-[260px] lg:col-span-2 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Hover Gradient Border */}
            <div 
              className="absolute inset-0 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none z-20" 
              style={{
                padding: '1.5px',
                background: 'linear-gradient(to bottom right, rgba(94, 23, 235, 0.4), rgba(168, 85, 247, 0.1), rgba(94, 23, 235, 0.4))',
                WebkitMask: 'linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)',
                WebkitMaskComposite: 'xor',
                maskComposite: 'exclude'
              }}
            ></div>
            {/* Subtle Purple Glow */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#5e17eb]/[0.03] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none z-0"></div>
            
            {/* AI Powered Badge */}
            <span className="absolute top-6 right-6 px-2.5 py-1 bg-gradient-to-r from-[#5e17eb]/10 to-purple-500/10 border border-[#5e17eb]/20 rounded-full text-[9px] font-bold text-[#5e17eb] uppercase tracking-widest z-20 shadow-sm backdrop-blur-md">
              AI Powered
            </span>

            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-[#5e17eb]/5 pointer-events-none transform group-hover:scale-105 group-hover:rotate-6 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M25 15 H60 L80 35 V85 A5 5 0 0 1 75 90 H25 A5 5 0 0 1 20 85 V20 A5 5 0 0 1 25 15 Z" stroke="currentColor" strokeWidth="3" strokeLinejoin="round" />
                <path d="M60 15 V35 H80" stroke="currentColor" strokeWidth="3" strokeLinejoin="round" />
                <line x1="35" y1="45" x2="65" y2="45" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
                <line x1="35" y1="60" x2="65" y2="60" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
                <line x1="35" y1="75" x2="50" y2="75" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#5e17eb] to-purple-600 flex items-center justify-center text-white mb-5 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-md shadow-[#5e17eb]/20">
                <FileText className="w-5 h-5" />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2.5 tracking-tight group-hover:text-[#5e17eb] transition-colors duration-300">AI Portfolio Analysis</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium max-w-2xl">
                Leverage real-time semantic parsing to analyze portfolio schemas and matching scores against active corporate profiles. Standardize formatting structure and ensure compliance with ATS models.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-[#5e17eb] mt-4 flex items-center gap-1 relative z-10 uppercase tracking-wide">Analysis Engine • Standardized Audit Trail</span>
          </div>

          {/* Card 2 - Skill Assessment (Span 1, Tall Card / row-span-2) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 group flex flex-col justify-between lg:row-span-2 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-slate-200/50 pointer-events-none transform group-hover:scale-105 group-hover:-rotate-6 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="50" cy="50" r="35" stroke="currentColor" strokeWidth="2" />
                <circle cx="50" cy="50" r="20" stroke="currentColor" strokeWidth="2" strokeDasharray="2 2" />
                <path d="M50 15 L50 85 M15 50 L85 50" stroke="currentColor" strokeWidth="1.5" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-650 mb-5 group-hover:bg-slate-100 group-hover:text-slate-900 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-sm">
                <Brain className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2.5 tracking-tight">Skill Assessments</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                Proctored assessments evaluating technical competence and logical frameworks. Integrated browser lock and cognitive anomaly indicators ensure absolute grading integrity.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-slate-500 mt-4 block relative z-10 uppercase tracking-wide">Security Shield Active</span>
          </div>

          {/* Card 3 - Learning Roadmap (Span 1) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 group flex flex-col justify-between col-span-1 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-slate-200/50 pointer-events-none transform group-hover:scale-105 group-hover:rotate-12 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M15 85 C 40 85, 30 50, 50 50 C 70 50, 60 15, 85 15" stroke="currentColor" strokeWidth="4" strokeLinecap="round" strokeDasharray="6 6" />
                <circle cx="15" cy="85" r="5" stroke="currentColor" strokeWidth="3" fill="none" />
                <circle cx="50" cy="50" r="5" stroke="currentColor" strokeWidth="3" fill="none" />
                <path d="M85 25 V10 M85 10 L70 15 L85 20" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-600 mb-5 group-hover:bg-slate-100 group-hover:text-slate-900 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-sm">
                <BookOpen className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2.5 tracking-tight">Personalized Learning</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                Generate target learning pathing and code exercises to resolve specific capability gaps captured during evaluations.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-slate-500 mt-4 block relative z-10 uppercase tracking-wide">Adaptive Pathing System</span>
          </div>

          {/* Card 6 - College Analytics (Span 1) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 group flex flex-col justify-between col-span-1 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-slate-200/50 pointer-events-none transform group-hover:scale-105 group-hover:translate-x-1 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M15 15 V85 H85" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
                <path d="M15 70 L35 45 L55 55 L80 20" stroke="currentColor" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round" />
                <circle cx="35" cy="45" r="4" fill="currentColor" />
                <circle cx="55" cy="55" r="4" fill="currentColor" />
                <circle cx="80" cy="20" r="4" fill="currentColor" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-600 mb-5 group-hover:bg-slate-100 group-hover:text-slate-900 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-sm">
                <Database className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2.5 tracking-tight">Placement Analytics</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                Track aggregate cohort readiness indices, evaluate assessment parameters, and audit enterprise engagement statistics from a central console.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-slate-500 mt-4 block relative z-10 uppercase tracking-wide">Cohort Metrics Console</span>
          </div>

          {/* Card 7 - Mentorship Tracking (Span 1, Tall Card / row-span-2) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 group flex flex-col justify-between lg:row-span-2 col-span-1 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-slate-200/50 pointer-events-none transform group-hover:scale-105 group-hover:-translate-y-1 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="35" cy="40" r="15" stroke="currentColor" strokeWidth="2" />
                <circle cx="65" cy="40" r="15" stroke="currentColor" strokeWidth="2" />
                <path d="M15 80 C 15 65, 55 65, 55 80" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                <path d="M45 80 C 45 68, 85 68, 85 80" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-600 mb-5 group-hover:bg-slate-100 group-hover:text-slate-900 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-sm">
                <MessageSquare className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 mb-2.5 tracking-tight">Mentor Reviews</h3>
              <p className="text-xs text-slate-505 leading-relaxed font-medium">
                Coordinate mock technical panels and portfolio reviews within an integrated audit trail. Connect cohorts with industry professionals for specialized code check-ins.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-slate-500 mt-4 block relative z-10 uppercase tracking-wide">Advisory Evaluations</span>
          </div>

          {/* Card 4 - Candidate Matching (Span 2) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 lg:p-8 group flex flex-col justify-between min-h-[220px] lg:col-span-2 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Hover Gradient Border */}
            <div 
              className="absolute inset-0 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none z-20" 
              style={{
                padding: '1.5px',
                background: 'linear-gradient(to bottom right, rgba(94, 23, 235, 0.4), rgba(168, 85, 247, 0.1), rgba(94, 23, 235, 0.4))',
                WebkitMask: 'linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)',
                WebkitMaskComposite: 'xor',
                maskComposite: 'exclude'
              }}
            ></div>
            {/* Subtle Purple Glow */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#5e17eb]/[0.03] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none z-0"></div>
            
            {/* AI Powered Badge */}
            <span className="absolute top-6 right-6 px-2.5 py-1 bg-gradient-to-r from-[#5e17eb]/10 to-purple-500/10 border border-[#5e17eb]/20 rounded-full text-[9px] font-bold text-[#5e17eb] uppercase tracking-widest z-20 shadow-sm backdrop-blur-md">
              AI Powered
            </span>

            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-[#5e17eb]/5 pointer-events-none transform group-hover:scale-105 group-hover:rotate-45 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <line x1="50" y1="20" x2="20" y2="50" stroke="currentColor" strokeWidth="3" />
                <line x1="50" y1="20" x2="80" y2="50" stroke="currentColor" strokeWidth="3" />
                <line x1="20" y1="50" x2="35" y2="80" stroke="currentColor" strokeWidth="3" />
                <line x1="80" y1="50" x2="65" y2="80" stroke="currentColor" strokeWidth="3" />
                <line x1="35" y1="80" x2="65" y2="80" stroke="currentColor" strokeWidth="3" />
                <line x1="20" y1="50" x2="80" y2="50" stroke="currentColor" strokeWidth="3" opacity="0.4" />
                <circle cx="50" cy="20" r="7" fill="currentColor" />
                <circle cx="20" cy="50" r="6" fill="currentColor" />
                <circle cx="80" cy="50" r="6" fill="currentColor" />
                <circle cx="35" cy="80" r="5" fill="currentColor" />
                <circle cx="65" cy="80" r="5" fill="currentColor" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#5e17eb] to-purple-600 flex items-center justify-center text-white mb-5 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-md shadow-[#5e17eb]/20">
                <Cpu className="w-5 h-5" />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2.5 tracking-tight group-hover:text-[#5e17eb] transition-colors duration-300">AI Job Matching</h3>
              <p className="text-xs text-slate-555 leading-relaxed font-medium max-w-2xl">
                Filter out noise by matching candidate competency embeddings against specific functional roles. Bypasses keyword stuffing with semantic index matching.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-[#5e17eb] mt-4 flex items-center gap-1 relative z-10 uppercase tracking-wide">Alignment Index • 99.4% Accuracy</span>
          </div>

          {/* Card 5 - Recruiter Hub (Span 2) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 lg:p-8 group flex flex-col justify-between min-h-[220px] lg:col-span-2 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-slate-200/50 pointer-events-none transform group-hover:scale-105 group-hover:scale-110 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="10" y="15" width="80" height="70" rx="6" stroke="currentColor" strokeWidth="3" />
                <line x1="30" y1="15" x2="30" y2="85" stroke="currentColor" strokeWidth="3" />
                <line x1="10" y1="30" x2="90" y2="30" stroke="currentColor" strokeWidth="3" />
                <rect x="15" y="40" width="10" height="4" rx="2" fill="currentColor" />
                <rect x="15" y="52" width="10" height="4" rx="2" fill="currentColor" opacity="0.5" />
                <rect x="15" y="64" width="10" height="4" rx="2" fill="currentColor" opacity="0.5" />
                <rect x="38" y="40" width="20" height="15" rx="3" stroke="currentColor" strokeWidth="2" />
                <rect x="64" y="40" width="20" height="15" rx="3" stroke="currentColor" strokeWidth="2" />
                <rect x="38" y="62" width="46" height="15" rx="3" stroke="currentColor" strokeWidth="2" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-650 mb-5 group-hover:bg-slate-100 group-hover:text-slate-900 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-sm">
                <BarChart3 className="w-5 h-5" />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2.5 tracking-tight">Recruiter Workspace</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium max-w-2xl">
                Manage pipeline stages, schedule panel interviews, verify credential checks, and initiate outreach. Optimize screening cycles by up to 10x with validated cohorts.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-slate-505 mt-4 flex items-center gap-1 relative z-10 uppercase tracking-wide">Enterprise Sourcing Portal</span>
          </div>

          {/* Card 8 - Placement Monitoring (Span 1) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 group flex flex-col justify-between col-span-1 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-slate-200/50 pointer-events-none transform group-hover:scale-105 group-hover:-rotate-12 transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M50 15 L80 35 L80 65 L50 85 L20 65 L20 35 Z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round" />
                <path d="M50 35 L50 65" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                <circle cx="50" cy="65" r="4" fill="currentColor" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-600 mb-5 group-hover:bg-slate-100 group-hover:text-slate-900 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-sm">
                <Award className="w-5 h-5" />
              </div>
              <h3 className="text-lg font-bold text-slate-900 mb-2.5 tracking-tight">Placement Tracking</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium">
                Audit formal offers, coordinate onboarding compliance, verify credentials, and generate institutional verification reports.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-slate-505 mt-4 block relative z-10 uppercase tracking-wide">Validation Ledger</span>
          </div>

          {/* Card 9 - AI Mock Interviews (Span 2) */}
          <div className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl p-6 lg:p-8 group flex flex-col justify-between min-h-[220px] lg:col-span-2 relative overflow-hidden hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300">
            {/* Hover Gradient Border */}
            <div 
              className="absolute inset-0 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none z-20" 
              style={{
                padding: '1.5px',
                background: 'linear-gradient(to bottom right, rgba(94, 23, 235, 0.4), rgba(168, 85, 247, 0.1), rgba(94, 23, 235, 0.4))',
                WebkitMask: 'linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)',
                WebkitMaskComposite: 'xor',
                maskComposite: 'exclude'
              }}
            ></div>
            {/* Subtle Purple Glow */}
            <div className="absolute inset-0 bg-gradient-to-br from-[#5e17eb]/[0.03] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-505 pointer-events-none z-0"></div>
            
            {/* AI Powered Badge */}
            <span className="absolute top-6 right-6 px-2.5 py-1 bg-gradient-to-r from-[#5e17eb]/10 to-purple-500/10 border border-[#5e17eb]/20 rounded-full text-[9px] font-bold text-[#5e17eb] uppercase tracking-widest z-20 shadow-sm backdrop-blur-md">
              AI Powered
            </span>

            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-4 right-4 w-24 h-24 text-[#5e17eb]/5 pointer-events-none transform group-hover:scale-105 group-hover:translate-y-[-2px] transition-all duration-500 ease-out z-0">
              <svg className="w-full h-full" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="35" y="15" width="30" height="45" rx="15" stroke="currentColor" strokeWidth="4" fill="none" />
                <line x1="45" y1="20" x2="45" y2="55" stroke="currentColor" strokeWidth="2" strokeLinecap="round" opacity="0.5" />
                <line x1="55" y1="20" x2="55" y2="55" stroke="currentColor" strokeWidth="2" strokeLinecap="round" opacity="0.5" />
                <path d="M25 45 C 25 65, 75 65, 75 45" stroke="currentColor" strokeWidth="4" strokeLinecap="round" fill="none" />
                <line x1="50" y1="67" x2="50" y2="85" stroke="currentColor" strokeWidth="4" strokeLinecap="round" />
                <line x1="35" y1="85" x2="65" y2="85" stroke="currentColor" strokeWidth="4" strokeLinecap="round" />
              </svg>
            </div>
            <div className="relative z-10">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#5e17eb] to-purple-600 flex items-center justify-center text-white mb-5 group-hover:scale-110 group-hover:rotate-3 transition-all duration-300 shadow-md shadow-[#5e17eb]/20">
                <Mic className="w-5 h-5" />
              </div>
              <h3 className="text-xl font-bold text-slate-900 mb-2.5 tracking-tight group-hover:text-[#5e17eb] transition-colors duration-300">AI Interview Coach</h3>
              <p className="text-xs text-slate-500 leading-relaxed font-medium max-w-2xl">
                Conduct realistic proctored panels, receive instant feedback, and refine communication metrics. Use speech analytics to evaluate technical vocabularies.
              </p>
            </div>
            <span className="text-[10px] font-semibold text-[#5e17eb] mt-4 flex items-center gap-1 relative z-10 uppercase tracking-wide">Speech Analytics System</span>
          </div>

          {/* Card 10 - Book A Demo (Span 3 / Full Width Bento Bottom Banner) */}
          <div className="bg-gradient-to-r from-[#5e17eb] to-indigo-955 border border-white/10 hover:shadow-2xl hover:shadow-[#5e17eb]/20 hover:-translate-y-1 transition-all duration-300 rounded-3xl p-6 lg:p-8 group col-span-1 md:col-span-2 lg:col-span-3 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 relative overflow-hidden">
            {/* Decorative SVG Graphic Accent */}
            <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full blur-[80px] pointer-events-none transform group-hover:scale-110 transition-transform duration-500"></div>
            <div className="max-w-2xl relative z-10">
              <div className="inline-flex items-center space-x-2 px-2.5 py-0.5 rounded-full bg-white/20 border border-white/30 text-[10px] font-bold text-white mb-3 uppercase tracking-wide">
                <Calendar className="w-3 h-3 text-white" />
                <span>Live Demo</span>
              </div>
              <h3 className="text-xl font-bold text-white mb-1.5 tracking-tight">Ready to Modernize Campus Placements?</h3>
              <p className="text-xs text-[#e0d4fc] leading-relaxed font-medium">
                Schedule a personalized demo to discover how C2C streamlines assessments, AI matching, recruiter collaboration, and placement analytics.
              </p>
            </div>
            <a
              href="#cta"
              className="group inline-flex items-center justify-center px-6 py-3 rounded-xl bg-white text-[#5e17eb] hover:bg-slate-50 text-xs font-bold transition-all duration-300 shadow-lg shadow-black/10 shrink-0 w-full md:w-auto hover:scale-[1.03] active:scale-[0.98] relative z-10"
            >
              Book a Demo
              <ArrowRight className="ml-2 w-4 h-4 group-hover:translate-x-1 transition-transform duration-300" />
            </a>
          </div>

        </div>
      </ScrollReveal>

      {/* 6. Stakeholder Ecosystem Section */}
      <ScrollReveal id="ecosystem" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-16 items-center">

            {/* Left text column */}
            <div className="lg:col-span-5 flex flex-col space-y-6">
              <span className="px-3.5 py-1.5 rounded-full bg-[#5e17eb]/10 border border-[#5e17eb]/20 text-xs font-bold text-[#5e17eb] shadow-sm uppercase tracking-wider w-fit">
                CONNECTED ECOSYSTEM
              </span>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-slate-900 tracking-tight leading-tight">
                One Ecosystem. Infinite Opportunities.
              </h2>
              <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
                C2C connects students, institutions, mentors, recruiters, and enterprises through one intelligent platform—eliminating fragmented workflows and enabling seamless collaboration.
              </p>

              <div ref={stakeholderContainerRef} className="space-y-4">
                {stakeholders.map((sh) => {
                  const isActive = activeStakeholder === sh.id;
                  const isAnyActive = activeStakeholder !== null;
                  
                  return (
                    <div
                      key={sh.id}
                      onClick={() => setActiveStakeholder(isActive ? null : sh.id)}
                      className={`p-5 rounded-3xl border cursor-pointer transition-all duration-500 ease-[cubic-bezier(0.16,1,0.3,1)] ${
                        isActive
                          ? 'bg-white/90 border-[#5e17eb] shadow-2xl shadow-[#5e17eb]/10 scale-[1.03] z-10'
                          : isAnyActive
                            ? 'bg-white/40 border-white/20 opacity-50 scale-[0.97] blur-[0.3px]'
                            : 'bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] hover:-translate-y-0.5 hover:shadow-[0_20px_40px_rgb(99,102,241,0.03)]'
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-bold text-slate-800">{sh.name}</span>
                        <ChevronRight className={`w-4 h-4 transition-transform duration-300 ${isActive ? 'text-[#5e17eb] rotate-90' : 'text-slate-400'}`} />
                      </div>
                      {isActive && (
                        <div className="mt-3.5 pt-3.5 border-t border-slate-100 transition-all duration-500 animate-in fade-in slide-in-from-top-2">
                          <p className="text-xs text-slate-505 leading-relaxed font-medium mb-4">
                            {sh.desc}
                          </p>
                          
                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-y-2.5 gap-x-4 mb-4">
                            {sh.features.map((feature, idx) => (
                              <div key={idx} className="flex items-center space-x-2">
                                <div className="w-4 h-4 rounded-full bg-[#5e17eb]/10 flex items-center justify-center shrink-0">
                                  <Check className="w-2.5 h-2.5 text-[#5e17eb]" />
                                </div>
                                <span className="text-[11px] font-semibold text-slate-705 leading-tight">{feature}</span>
                              </div>
                            ))}
                          </div>

                          <div className="flex items-center space-x-3 bg-slate-50 p-2.5 rounded-xl border border-slate-100/80">
                            <span className="text-xl font-black text-[#5e17eb]">{sh.kpi.value}</span>
                            <span className="text-[10px] uppercase tracking-wide font-bold text-slate-500">{sh.kpi.label}</span>
                          </div>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Right mesh grid layout */}
            <div className="lg:col-span-7 relative flex items-center justify-center">

              {/* Radial background blur */}
              <div className="absolute inset-0 bg-[#5e17eb]/10 rounded-full blur-[100px] pointer-events-none w-[600px] h-[600px] top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"></div>

              {/* Main Visual Node Map container */}
              <div className="relative w-full max-w-[500px] aspect-square flex items-center justify-center bg-white/80 backdrop-blur-md border border-white/60 rounded-3xl p-8 shadow-[0_8px_30px_rgb(0,0,0,0.02)] overflow-hidden">

                {/* SVG Connections with Animations */}
                <svg viewBox="0 0 500 500" className="absolute inset-0 w-full h-full z-0 pointer-events-none">
                  <defs>
                    <linearGradient id="lineGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#5e17eb" stopOpacity="0.1" />
                      <stop offset="50%" stopColor="#5e17eb" stopOpacity="0.4" />
                      <stop offset="100%" stopColor="#5e17eb" stopOpacity="0.1" />
                    </linearGradient>
                    <radialGradient id="pulseGrad">
                      <stop offset="0%" stopColor="#5e17eb" stopOpacity="0.25" />
                      <stop offset="100%" stopColor="#5e17eb" stopOpacity="0" />
                    </radialGradient>
                    <filter id="glow">
                      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                      <feMerge>
                        <feMergeNode in="coloredBlur"/>
                        <feMergeNode in="SourceGraphic"/>
                      </feMerge>
                    </filter>
                  </defs>

                  <style dangerouslySetInnerHTML={{ __html: `
                    @keyframes dashFlow {
                      to { stroke-dashoffset: -20; }
                    }
                    .flow-line {
                      animation: dashFlow 1s linear infinite;
                    }
                  `}} />

                  {/* Base Lines */}
                  <line x1="60" y1="200" x2="440" y2="200" stroke="url(#lineGrad)" strokeWidth="2" strokeDasharray="6 4" className="flow-line" />
                  <line x1="250" y1="60" x2="250" y2="440" stroke="url(#lineGrad)" strokeWidth="2" strokeDasharray="6 4" className="flow-line" />
                  
                  {/* Glowing Core Lines */}
                  <line x1="60" y1="200" x2="440" y2="200" stroke="#5e17eb" strokeWidth="1" opacity="0.3" />
                  <line x1="250" y1="60" x2="250" y2="440" stroke="#5e17eb" strokeWidth="1" opacity="0.3" />

                  {/* Animated Particles */}
                  <circle r="4" fill="#5e17eb" filter="url(#glow)">
                    <animateMotion dur="2s" repeatCount="indefinite" path="M 60 200 L 250 200" />
                  </circle>
                  <circle r="4" fill="#5e17eb" filter="url(#glow)">
                    <animateMotion dur="2s" repeatCount="indefinite" path="M 250 200 L 440 200" />
                  </circle>
                  <circle r="4" fill="#5e17eb" filter="url(#glow)">
                    <animateMotion dur="2.5s" repeatCount="indefinite" path="M 250 60 L 250 200" />
                  </circle>
                  <circle r="4" fill="#5e17eb" filter="url(#glow)">
                    <animateMotion dur="2s" repeatCount="indefinite" path="M 250 200 L 250 340" />
                  </circle>
                  <circle r="4" fill="#5e17eb" filter="url(#glow)">
                    <animateMotion dur="1.5s" repeatCount="indefinite" path="M 250 340 L 250 440" />
                  </circle>
                  
                  {/* Pulse Rings */}
                  <circle cx="250" cy="200" r="30" fill="url(#pulseGrad)">
                     <animate attributeName="r" values="30; 70; 30" dur="4s" repeatCount="indefinite" />
                     <animate attributeName="opacity" values="0.8; 0; 0.8" dur="4s" repeatCount="indefinite" />
                  </circle>
                  <circle cx="250" cy="340" r="20" fill="url(#pulseGrad)">
                     <animate attributeName="r" values="20; 50; 20" dur="3s" repeatCount="indefinite" begin="1s" />
                     <animate attributeName="opacity" values="0.6; 0; 0.6" dur="3s" repeatCount="indefinite" begin="1s" />
                  </circle>
                </svg>

                {/* Center Core Engine Node */}
                <div 
                  className="absolute w-24 h-24 rounded-full bg-gradient-to-br from-[#5e17eb] to-purple-700 flex flex-col items-center justify-center shadow-[0_0_40px_rgba(94,23,235,0.4)] z-20 border-4 border-white transform -translate-x-1/2 -translate-y-1/2 transition-transform duration-500 hover:scale-110 cursor-pointer"
                  style={{ top: '40%', left: '50%' }}
                >
                  <span className="text-white font-extrabold text-2xl tracking-tighter leading-none">C2C</span>
                  <span className="text-[8px] text-[#e0d4fc] uppercase tracking-widest font-black mt-1.5">Core Engine</span>
                </div>

                {/* Network Nodes */}
                {[
                  { id: 'student', name: 'Student', top: '12%', left: '50%', icon: GraduationCap },
                  { id: 'mentor', name: 'Mentor', top: '40%', left: '12%', icon: Users },
                  { id: 'recruiter', name: 'Recruiter', top: '40%', left: '88%', icon: Briefcase },
                  { id: 'college', name: 'Institution', top: '68%', left: '50%', icon: Building },
                  { id: 'company', name: 'Enterprise', top: '88%', left: '50%', icon: Target },
                ].map((node) => {
                  const isActive = hoveredStakeholder === node.id;
                  return (
                    <div
                      key={node.id}
                      className={`absolute flex flex-col items-center transition-all duration-300 z-10 transform -translate-x-1/2 -translate-y-1/2 ${isActive ? 'scale-110' : 'scale-100 opacity-95'}`}
                      style={{ top: node.top, left: node.left }}
                      onMouseEnter={() => setHoveredStakeholder(node.id)}
                      onMouseLeave={() => setHoveredStakeholder(null)}
                      onClick={() => {
                        if (node.id === 'mentor') {
                          navigate('/mentor-dashboard');
                        }
                      }}
                    >
                      <div className={`w-12 h-12 rounded-2xl bg-slate-50 border ${isActive ? 'border-[#5e17eb] shadow-xl bg-white shadow-[#5e17eb]/20' : 'border-slate-200'} flex items-center justify-center text-slate-700 transition-all duration-300 shadow-sm relative cursor-pointer`}>
                        <node.icon className={`w-5 h-5 ${isActive ? 'text-[#5e17eb]' : 'text-slate-500'}`} />
                        {/* Hover ring effect */}
                        {isActive && <div className="absolute inset-0 rounded-2xl border-2 border-[#5e17eb] animate-ping opacity-20"></div>}
                      </div>
                      <span className={`text-[9px] font-bold mt-2 px-2.5 py-1 rounded-md border shadow-sm transition-all duration-305 ${isActive ? 'bg-[#5e17eb] border-[#5e17eb] text-white' : 'bg-white border-slate-200/80 text-slate-700'}`}>
                        {node.name}
                      </span>
                    </div>
                  );
                })}

                {/* Animated grid background effect inside node panel */}
                <div className="absolute inset-0 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] bg-[size:32px_32px] rounded-3xl opacity-40 pointer-events-none z-0"></div>

              </div>
            </div>

          </div>
        </div>
      </ScrollReveal>

      {/* Structural visual transition element */}
      <div className="relative h-24 w-full bg-gradient-to-b from-slate-50/50 to-white overflow-hidden pointer-events-none">
        <svg className="absolute bottom-0 w-full h-12 text-slate-50/30 fill-current" viewBox="0 0 1440 74" fill="none">
          <path d="M0,32L120,42.7C240,53,480,75,720,74.7C960,75,1200,53,1320,42.7L1440,32L1440,74L1320,74C1200,74,960,74,720,74C480,74,240,74,120,74L0,74Z" />
        </svg>
      </div>

      {/* 9. How It Works Section */}
      <ScrollReveal id="how-it-works" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 overflow-hidden">
        <div className="absolute top-0 right-1/4 w-[400px] h-[400px] bg-purple-100/40 rounded-full blur-[100px] pointer-events-none"></div>
        
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="px-3.5 py-1.5 rounded-full bg-purple-50 border border-purple-100 text-xs font-bold text-purple-700 shadow-sm">
              Ecosystem Blueprint
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight font-sans">
              How the Campus Bridge Works
            </h2>
            <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
              A transparent, end-to-end talent verification and pipeline delivery process mapping campus readiness straight to recruiter screens.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              {
                step: '01',
                title: 'Profile Setup',
                desc: 'Students authenticate credentials using standard Google parameters and import their profile fields.',
                color: 'text-purple-600 border-purple-100 bg-purple-50/50'
              },
              {
                step: '02',
                title: 'Skill Verification',
                desc: 'Candidates undergo automated assessment testing, coding trials, and mentor validation loops.',
                color: 'text-emerald-600 border-emerald-100 bg-emerald-50/50'
              },
              {
                step: '03',
                title: 'AI Gap Engineering',
                desc: 'AI systems run deep matching checks to discover candidate profile weaknesses and alignment indicators.',
                color: 'text-blue-600 border-blue-100 bg-blue-50/50'
              },
              {
                step: '04',
                title: 'Direct Placement',
                desc: 'Pre-validated student portfolios match recruiter dashboard criteria for instant placement unlocked.',
                color: 'text-orange-500 border-orange-100 bg-orange-50/50'
              }
            ].map((item) => (
              <div key={item.step} className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] p-6 rounded-3xl relative group hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.05)] transition-all duration-300 text-left">
                <div className={`w-12 h-12 rounded-2xl border flex items-center justify-center text-lg font-black ${item.color} mb-5`}>
                  {item.step}
                </div>
                <h3 className="text-base font-extrabold text-slate-800 tracking-tight">{item.title}</h3>
                <p className="text-xs text-slate-500 mt-2 leading-relaxed font-semibold">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </ScrollReveal>

      {/* 10. Placement Success Stories Section */}
      <ScrollReveal id="success-stories" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 border-t border-slate-200/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="px-3.5 py-1.5 rounded-full bg-emerald-50 border border-emerald-100 text-xs font-bold text-emerald-700 shadow-sm">
              Placement Outcomes
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight">
              Real Paths. Verified Success.
            </h2>
            <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
              See how verified technical credentials and institutional pipelines transform student career trajectories.
            </p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {[
              {
                id: 'story-1',
                name: 'Gaurav ',
                role: 'Software Engineer',
                company: 'Amazon',
                package: '₹12 LPA Package',
                before: 'Missing verified technical credentials, unoptimized ATS resume fields, and manual placement tracking.',
                after: 'Placed via the institutional bridge with a 94th percentile verified rating and automated recruiter outreach.'
              },
              {
                id: 'story-2',
                name: 'Khushi',
                role: 'Frontend Architect',
                company: 'Stripe',
                package: '₹16 LPA Package',
                before: 'Fragmented project proof, unvalidated skills portfolio, and manual outreach loops.',
                after: 'Direct matching sync triggered an interview request on the Recruiter Hub within 48 hours of verification.'
              }
            ].map((story) => (
              <div key={story.id} className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-[28px] p-6 sm:p-8 flex flex-col justify-between text-left hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.04)] transition-all duration-300">
                <div>
                  <div className="flex items-center justify-between pb-4 border-b border-slate-100">
                    <div>
                      <h3 className="text-lg font-extrabold text-slate-900">{story.name}</h3>
                      <p className="text-xs text-slate-400 font-semibold">{story.role} · {story.company}</p>
                    </div>
                    <span className="px-3.5 py-1.5 bg-emerald-50 border border-emerald-100 text-emerald-700 rounded-xl text-xs font-bold shadow-sm">
                      {story.package}
                    </span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 mt-6 text-xs leading-relaxed font-semibold">
                    <div className="p-4 bg-red-50/50 border border-red-100 rounded-2xl">
                      <span className="block text-[9px] uppercase tracking-wider text-red-500 font-black mb-2">Before Platform</span>
                      <p className="text-slate-600">{story.before}</p>
                    </div>

                    <div className="p-4 bg-emerald-50/50 border border-emerald-100 rounded-2xl">
                      <span className="block text-[9px] uppercase tracking-wider text-emerald-600 font-black mb-2">After Placement Sync</span>
                      <p className="text-slate-700">{story.after}</p>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </ScrollReveal>

      {/* 11. Upcoming Workshops & Live Career Events */}
      <ScrollReveal id="events" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 border-t border-slate-200/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="px-3.5 py-1.5 rounded-full bg-blue-50 border border-blue-100 text-xs font-bold text-blue-700 shadow-sm">
              Live Calendar
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight">
              Upcoming Workshops & Live Events
            </h2>
            <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
              Accelerate candidate prep work and connect with active industry mentors during our weekly live ecosystem interactions.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {[
              {
                id: 'event-1',
                title: 'FAANG Mock Interview Simulation Loop',
                host: 'Lead Corporate Mentors',
                time: 'Tomorrow, 4:00 PM IST',
                tag: 'Simulation Loop',
                tagColor: 'bg-purple-50 text-purple-700 border-purple-100'
              },
              {
                id: 'event-2',
                title: 'SaaS Resume Design Masterclass & Optimization',
                host: 'Talent Acquisition Specialists',
                time: 'Friday, 6:00 PM IST',
                tag: 'Resume Prep',
                tagColor: 'bg-blue-50 text-blue-700 border-blue-100'
              }
            ].map((event) => (
              <div key={event.id} className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-[28px] p-6 flex flex-col justify-between text-left hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.04)] transition-all duration-300">
                <div>
                  <span className={`px-2.5 py-1 rounded-lg border text-[9px] font-black uppercase tracking-wider ${event.tagColor}`}>
                    {event.tag}
                  </span>
                  <h3 className="text-base font-extrabold text-slate-800 tracking-tight mt-4 leading-snug">{event.title}</h3>
                  
                  <div className="flex items-center space-x-2 mt-4 text-xs text-slate-500 font-semibold">
                    <span>By {event.host}</span>
                    <span>•</span>
                    <span className="text-slate-900 font-bold">{event.time}</span>
                  </div>
                </div>

                <div className="mt-6 pt-4 border-t border-slate-100">
                  <button className="w-full py-2.5 bg-gradient-to-r from-[#5e17eb] to-[#4b12bc] text-white font-bold rounded-xl text-xs shadow-sm hover:shadow-md transition-all cursor-pointer">
                    Register Slot
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </ScrollReveal>

      {/* 12. Latest Career Resources Hub Section */}
      <ScrollReveal id="resources" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 border-t border-slate-200/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="px-3.5 py-1.5 rounded-full bg-orange-50 border border-orange-100 text-xs font-bold text-orange-700 shadow-sm">
              Resources Hub
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight">
              Latest Prep & Placement Insights
            </h2>
            <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
              Boost placement preparedness using curated guides, sheets, and experience blueprints.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                id: 'resource-1',
                title: 'System Design Interview Fundamentals',
                category: 'Interview Preparation',
                desc: 'Understand key microservice concepts, horizontal scaling, and latency optimization rules.',
                color: 'text-purple-600'
              },
              {
                id: 'resource-2',
                title: 'Premium Single-Page Resume Template',
                category: 'Resume Templates',
                desc: 'Download the verified resume layout designed to score 90+ on automated ATS screening software.',
                color: 'text-emerald-600'
              },
              {
                id: 'resource-3',
                title: 'Data Structures & Algorithms Cheat Sheet',
                category: 'Coding Sheets',
                desc: 'Quickly reference complexity rules, tree traversal patterns, and graph algorithms.',
                color: 'text-blue-600'
              }
            ].map((res) => (
              <div key={res.id} className="bg-white/80 backdrop-blur-md border border-white/60 p-6 rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.02)] flex flex-col justify-between group hover:-translate-y-1 hover:shadow-[0_20px_40px_rgb(99,102,241,0.04)] transition-all duration-300 cursor-pointer text-left">
                <div>
                  <span className={`text-[9px] font-black uppercase tracking-wider ${res.color}`}>
                    {res.category}
                  </span>
                  <h3 className="text-sm font-extrabold text-slate-800 tracking-tight mt-3 group-hover:text-[#5e17eb] transition-colors">{res.title}</h3>
                  <p className="text-xs text-slate-505 mt-2 leading-relaxed font-semibold">{res.desc}</p>
                </div>
                <div className="flex items-center text-xs font-bold text-[#5e17eb] mt-6 gap-1 group-hover:gap-2 transition-all">
                  <span>Read Article</span>
                  <span>➔</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </ScrollReveal>

      {/* 13. Frequently Asked Questions (FAQ) Section */}
      <ScrollReveal id="faq" className="relative z-10 py-20 md:py-28 bg-[radial-gradient(#e2e8f0_1px,transparent_1px)] [background-size:24px_24px] bg-gradient-to-b from-white via-slate-50/50 to-slate-100/70 border-t border-slate-200/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16">
            <span className="px-3.5 py-1.5 rounded-full bg-slate-100 border border-slate-200 text-xs font-bold text-slate-600 shadow-sm">
              Common Questions
            </span>
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-slate-900 mt-5 tracking-tight">
              Frequently Asked Questions
            </h2>
            <p className="text-slate-600 antialiased leading-relaxed max-w-2xl mx-auto mt-4 text-base font-medium">
              Find instant clarification regarding single-role locks, campus metrics, and candidate coding badge validations.
            </p>
          </div>

          <div className="max-w-3xl mx-auto space-y-4">
            {[
              {
                id: 1,
                question: 'How does the platform guarantee single-role identity locks?',
                answer: 'Our client-side and server security rules restrict email registration configurations. A student profile cannot register as a mentor or college placement administrator, keeping user actions secure.'
              },
              {
                id: 2,
                question: 'Can we monitor live cohort attendance and task completion metrics?',
                answer: 'Yes. College admin dashboards track student profile verification levels, coding badge completions, and live workshop attendance trends in real time.'
              },
              {
                id: 3,
                question: 'How are candidate aptitude profiles and coding badge criteria verified?',
                answer: 'All assessment scores and coding tasks are reviewed through automated compiler checks and audited by industry mentors before syncing to recruiter workspaces.'
              }
            ].map((faq) => {
              const isOpen = activeFaq === faq.id;
              return (
                <div key={faq.id} className="bg-white/80 backdrop-blur-md border border-white/60 shadow-[0_8px_30px_rgb(0,0,0,0.02)] rounded-3xl overflow-hidden hover:shadow-[0_20px_40px_rgb(99,102,241,0.03)] hover:border-[#5e17eb]/30 transition-all duration-305 text-left">
                  <button
                    onClick={() => setActiveFaq(isOpen ? null : faq.id)}
                    className="w-full px-6 py-5 text-left font-bold text-slate-800 text-sm flex items-center justify-between hover:bg-slate-50 transition-colors"
                  >
                    <span>{faq.question}</span>
                    <span className={`text-base font-black transition-transform duration-300 ${isOpen ? 'rotate-45 text-[#5e17eb]' : 'text-slate-400'}`}>＋</span>
                  </button>
                  {isOpen && (
                    <div className="px-6 pb-5 text-xs text-slate-500 font-semibold leading-relaxed border-t border-slate-100 pt-4 animate-in fade-in slide-in-from-top-1 duration-300">
                      {faq.answer}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </ScrollReveal>

      {/* 14. CTA Section */}
      <ScrollReveal id="cta" className="relative z-10 py-20 md:py-28 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative rounded-3xl overflow-hidden bg-gradient-to-r from-slate-900 via-purple-950 to-indigo-955 border border-slate-800 p-8 md:p-16 text-center shadow-2xl">
          <div className="absolute top-0 left-0 w-80 h-80 bg-[#5e17eb]/15 rounded-full blur-[100px] pointer-events-none"></div>
          <div className="absolute bottom-0 right-0 w-80 h-80 bg-purple-500/15 rounded-full blur-[100px] pointer-events-none"></div>

          <div className="relative z-10 max-w-3xl mx-auto space-y-8">
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-black text-white tracking-tight leading-tight">
              Ready to transform your campus into a career powerhouse?
            </h2>
            <p className="text-base sm:text-lg text-slate-200 leading-relaxed max-w-2xl mx-auto font-medium">
              Join thousands of students, elite academic institutions, and corporate recruiters already optimizing employability outcomes today.
            </p>
            <div className="pt-6 flex flex-col sm:flex-row items-center justify-center gap-4">
              <button
                onClick={() => {
                  setShowAuthFlow(true);
                  setAuthScreen('select');
                }}
                className="group inline-flex items-center justify-center px-8 py-4 bg-gradient-to-r from-purple-600 to-indigo-600 hover:opacity-95 text-white font-bold rounded-xl text-xs shadow-lg shadow-purple-500/20 hover:shadow-purple-500/40 transition-all duration-300 transform hover:-translate-y-0.5 active:scale-[0.98] cursor-pointer"
              >
                Get Started Now
                <Zap className="ml-2 w-4 h-4 group-hover:scale-110 transition-transform duration-300" />
              </button>
              <button
                onClick={() => {
                  setShowAuthFlow(true);
                  setAuthScreen('select');
                }}
                className="px-8 py-4 bg-white/10 hover:bg-white/20 text-white font-bold rounded-xl text-xs border border-white/25 transition-all duration-300 cursor-pointer"
              >
                Request Live Demo
              </button>
            </div>
          </div>
        </div>
      </ScrollReveal>

      {/* ENTERPRISE-GRADE DIRECTORY FOOTER */}
      <footer className="relative z-10 bg-gradient-to-b from-slate-50 to-slate-100 border-t border-slate-200/60 pt-16 pb-8 text-slate-600 overflow-hidden">
        {/* Decorative Top Glow Bar */}
        <div className="absolute top-0 left-0 right-0 h-[3px] bg-gradient-to-r from-purple-500 via-[#5e17eb] to-indigo-500"></div>
        {/* Ambient Background Bloom */}
        <div className="absolute bottom-0 right-10 w-96 h-96 bg-[#5e17eb]/5 rounded-full blur-[100px] pointer-events-none"></div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">

          {/* Footer Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-12 pb-12">

            {/* Column 1: Brand (logo, description, social) */}
            <div className="lg:col-span-5 space-y-6">
              <LogoSVG className="h-9 w-auto" iconColor="text-[#5e17eb]" textColor="text-slate-900" />
              <p className="text-xs text-slate-500 leading-relaxed max-w-sm font-medium">
                Bridging the gap between academic potential and corporate excellence through verifiable skill metrics, proctored competency audits, and direct recruitment pathways.
              </p>
              <div className="flex items-center space-x-4 pt-2">
                <a href="#" className="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 hover:text-white hover:bg-[#5e17eb] hover:border-[#5e17eb] transition-all duration-300 shadow-sm" aria-label="LinkedIn">
                  <Linkedin className="w-4 h-4" />
                </a>
                <a href="#" className="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 hover:text-white hover:bg-[#5e17eb] hover:border-[#5e17eb] transition-all duration-300 shadow-sm" aria-label="Twitter">
                  <Twitter className="w-4 h-4" />
                </a>
                <a href="#" className="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 hover:text-white hover:bg-[#5e17eb] hover:border-[#5e17eb] transition-all duration-300 shadow-sm" aria-label="Website">
                  <Globe className="w-4 h-4" />
                </a>
              </div>
            </div>

            {/* Column 2: Platform */}
            <div className="lg:col-span-2 space-y-4">
              <h4 className="text-xs font-black text-slate-900 uppercase tracking-widest">Platform</h4>
              <ul className="space-y-3.5 text-xs font-semibold text-slate-500">
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Features</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Solutions</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Enterprise</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Security</a></li>
              </ul>
            </div>

            {/* Column 3: Resources */}
            <div className="lg:col-span-2 space-y-4">
              <h4 className="text-xs font-black text-slate-900 uppercase tracking-widest">Resources</h4>
              <ul className="space-y-3.5 text-xs font-semibold text-slate-500">
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Case Studies</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Whitepapers</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Documentation</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Blog</a></li>
              </ul>
            </div>

            {/* Column 4: Company */}
            <div className="lg:col-span-3 space-y-4">
              <h4 className="text-xs font-black text-slate-900 uppercase tracking-widest">Company</h4>
              <ul className="space-y-3.5 text-xs font-semibold text-slate-500">
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">About Us</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Careers</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Press</a></li>
                <li><a href="#" className="hover:text-[#5e17eb] transition-all duration-300 hover:translate-x-1.5 inline-block transform">Contact</a></li>
              </ul>
            </div>

          </div>

          {/* Footer Bottom Row */}
          <div className="pt-8 border-t border-slate-200/60 flex flex-col md:flex-row items-center justify-between gap-4">

            <div className="flex flex-col md:flex-row items-center gap-4 text-xs font-semibold text-slate-500">
              <div className="flex items-center gap-2">
                <LogoSVG className="h-5 w-auto" iconColor="text-[#5e17eb]" textColor="text-slate-900" />
                <span>&copy; {new Date().getFullYear()} Ashoksoft Technologies. All rights reserved.</span>
              </div>
              <div className="flex space-x-3 md:border-l md:border-slate-200 md:pl-4 items-center">
                <a href="#" className="hover:text-[#5e17eb] transition-colors">Privacy Policy</a>
                <span>•</span>
                <a href="#" className="hover:text-[#5e17eb] transition-colors">Terms of Service</a>
                <span>•</span>
                <button 
                  onClick={() => navigate('/admin/login')}
                  className="text-xs text-slate-400 hover:text-purple-600 transition-colors font-mono cursor-pointer"
                >
                  admin@2026
                </button>
              </div>
            </div>

            {/* Language/Region selector */}
            <div className="flex items-center space-x-2 bg-white border border-slate-200 px-3.5 py-2 rounded-xl text-xs text-slate-505 font-bold cursor-pointer hover:bg-slate-50 hover:text-slate-950 transition-all shadow-sm">
              <Globe className="w-3.5 h-3.5 text-slate-400" />
              <span>Global (English)</span>
            </div>

          </div>

        </div>
      </footer>

      {/* Mobile Drawer Panel */}
      {showMobileMenu && (
        <div className="fixed inset-0 z-40 lg:hidden bg-slate-900/40 backdrop-blur-sm transition-opacity duration-300">
          <div className="fixed top-20 left-0 right-0 bg-white/95 backdrop-blur-md border-b border-purple-100 shadow-2xl p-6 space-y-6 flex flex-col z-50 animate-in slide-in-from-top duration-300 text-left">
            <nav className="flex flex-col space-y-4 text-sm font-bold text-slate-700">
              <a href="#problem" onClick={() => setShowMobileMenu(false)} className="hover:text-[#5e17eb] transition-colors">Problem</a>
              <a href="#solution" onClick={() => setShowMobileMenu(false)} className="hover:text-[#5e17eb] transition-colors">Solution</a>
              <a href="#ecosystem" onClick={() => setShowMobileMenu(false)} className="hover:text-[#5e17eb] transition-colors">Ecosystem</a>
              <a href="#how-it-works" onClick={() => setShowMobileMenu(false)} className="hover:text-[#5e17eb] transition-colors">AI Engine</a>
            </nav>
            <div className="border-t border-purple-100 pt-4 flex flex-col space-y-3">
              {isAuthenticated ? (
                <>
                  <button
                    onClick={() => {
                      setShowMobileMenu(false);
                      redirectUserByRole(currentUser?.role || 'student');
                    }}
                    className="w-full text-center py-2.5 border border-purple-200 bg-white hover:bg-purple-50 rounded-xl text-xs font-semibold text-slate-750 transition-all cursor-pointer shadow-sm"
                  >
                    Go to Dashboard
                  </button>
                  <button
                    onClick={() => {
                      setShowMobileMenu(false);
                      logout();
                    }}
                    className="w-full text-center py-2.5 bg-red-600 hover:bg-red-700 text-xs font-bold text-white rounded-xl shadow-sm transition-all cursor-pointer"
                  >
                    Sign Out
                  </button>
                </>
              ) : (
                <>
                  <button
                    onClick={() => {
                      setShowMobileMenu(false);
                      setShowAuthFlow(true);
                      setAuthScreen('select');
                    }}
                    className="w-full text-center py-2.5 border border-purple-200 bg-white hover:bg-purple-50 rounded-xl text-xs font-semibold text-slate-750 transition-all cursor-pointer shadow-sm"
                  >
                    Login
                  </button>
                  <button
                    onClick={() => {
                      setShowMobileMenu(false);
                      setShowAuthFlow(true);
                      setAuthScreen('select');
                    }}
                    className="w-full text-center py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-xs font-bold text-white rounded-xl shadow-sm shadow-purple-500/20 transition-all cursor-pointer"
                  >
                    Get Started
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}

      {showAuthFlow && (
        <div className="fixed inset-0 z-[99999] flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 transition-all duration-300 text-left">
          <div className={`bg-white rounded-3xl shadow-2xl border border-purple-100 w-full ${
            authScreen === 'select' ? 'max-w-2xl' : 'max-w-md'
          } p-6 md:p-8 relative overflow-hidden flex flex-col transition-all duration-300 animate-in fade-in zoom-in-95 duration-200`}>
            
            {/* Close button */}
            <button 
              onClick={() => setShowAuthFlow(false)}
              className="absolute top-4 right-4 p-2 rounded-full hover:bg-slate-100 bg-slate-50 text-slate-400 hover:text-slate-700 transition-colors z-50 cursor-pointer"
            >
              <CloseIcon className="w-4 h-4" />
            </button>

            {authScreen === 'select' ? (
              <div className="space-y-6">
                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">Step 1: Choose Your Profile</h2>
                  <p className="text-xs text-slate-500 mt-1">Select the option that best describes you.</p>
                </div>

                {/* Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {[
                    {
                      id: 'Student' as const,
                      name: 'Student',
                      emoji: '👨‍🎓',
                      sub: 'Learn skills, take assessments, build projects and get placed.',
                      themeColor: 'bg-[#5e17eb] hover:bg-[#4b12bc]',
                      iconBg: 'bg-purple-50 text-[#5e17eb] border border-purple-100',
                      icon: GraduationCap
                    },
                    {
                      id: 'Recruiter' as const,
                      name: 'Recruiter',
                      emoji: '💼',
                      sub: 'Post jobs, find talent, conduct interviews and hire.',
                      themeColor: 'bg-purple-700 hover:bg-purple-800',
                      iconBg: 'bg-purple-50 text-purple-700 border border-purple-100',
                      icon: Briefcase
                    },
                    {
                      id: 'College' as const,
                      name: 'College',
                      emoji: '🏫',
                      sub: 'Track students progress, assign mentors and manage placements.',
                      themeColor: 'bg-indigo-600 hover:bg-indigo-700',
                      iconBg: 'bg-indigo-50 text-indigo-600 border border-indigo-100',
                      icon: Building
                    },
                    {
                      id: 'Mentor' as const,
                      name: 'Mentor',
                      emoji: '🧠',
                      sub: 'Guide students, conduct sessions and rate projects.',
                      themeColor: 'bg-emerald-600 hover:bg-emerald-700',
                      iconBg: 'bg-emerald-50 text-emerald-600 border border-emerald-100',
                      icon: Brain
                    }
                  ].map((role) => (
                    <div 
                      key={role.id}
                      className="border border-purple-100 rounded-2xl p-5 flex flex-col items-center justify-between text-center bg-white/90 hover:border-purple-300 hover:shadow-lg transition-all duration-300 group"
                    >
                      <div className="flex flex-col items-center">
                        <div className={`w-12 h-12 rounded-full flex items-center justify-center ${role.iconBg} shrink-0 text-xl`}>
                          <span>{role.emoji}</span>
                        </div>
                        <h3 className="text-sm font-bold text-slate-800 mt-4 flex items-center gap-1.5">
                          <span>{role.name}</span>
                        </h3>
                        <p className="text-[11px] text-slate-500 leading-relaxed mt-2.5 px-2 font-semibold">
                          {role.sub}
                        </p>
                      </div>
                      <div className="w-full flex gap-2 mt-5">
                        <button
                          onClick={() => {
                            setSelectedRole(role.id);
                            setAuthScreen('signup');
                          }}
                          className={`flex-1 ${role.themeColor} text-white font-bold rounded-xl text-xs py-2.5 transition-all duration-200 cursor-pointer flex items-center justify-center gap-1 shadow-sm group-hover:-translate-y-0.5`}
                        >
                          <span>Sign Up</span>
                        </button>
                        <button
                          onClick={() => {
                            setSelectedRole(role.id);
                            setAuthScreen('login');
                          }}
                          className="flex-1 bg-purple-50 hover:bg-purple-100 text-[#5e17eb] font-bold border border-purple-200 rounded-xl text-xs py-2.5 transition-all duration-200 cursor-pointer flex items-center justify-center gap-1 shadow-sm"
                        >
                          <span>Login</span>
                        </button>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Footer Security Badge */}
                <div className="bg-purple-50/60 border border-purple-100 p-3.5 rounded-2xl flex items-start gap-3 mt-4">
                  <ShieldCheckIcon className="text-purple-600 w-4.5 h-4.5 mt-0.5 shrink-0" />
                  <p className="text-[10px] text-slate-600 leading-normal font-bold">
                    <span className="font-extrabold text-slate-800">One Email. One Identity. One Role. </span>
                    {"You can create only one account with your email/phone number."}
                  </p>
                </div>
              </div>
            ) : authScreen === 'admin-login' ? (
              <div className="space-y-6">
                {/* Back button */}
                <button 
                  onClick={() => setAuthScreen('select')}
                  className="flex items-center gap-1.5 text-[10px] font-black uppercase text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                  disabled={formLoading}
                >
                  <ChevronLeftIcon className="w-4 h-4" />
                  <span>Return to Role Selection</span>
                </button>

                {/* Top Badge */}
                <div className="flex items-center justify-between border-b border-purple-50 pb-3">
                  <div className="flex items-center gap-2 bg-purple-50 border border-purple-200/60 px-3 py-1 rounded-full">
                    <ShieldCheckIcon className="w-3.5 h-3.5 text-[#7C3AED]" />
                    <span className="text-[10px] font-extrabold text-[#7C3AED] uppercase tracking-wider">
                      Restricted Enterprise Portal
                    </span>
                  </div>
                  <span className="text-[10px] font-mono font-bold text-slate-400">
                    Admin@2026
                  </span>
                </div>

                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">
                    C2C Administrative Control Portal
                  </h2>
                  <p className="text-xs text-slate-500 mt-1 leading-relaxed">
                    {"Enter authorized administrative credentials to access platform controls."}
                  </p>
                </div>

                {formError && (
                  <div className="bg-red-50 text-red-650 border border-red-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formError}
                  </div>
                )}
                {formSuccess && (
                  <div className="bg-emerald-50 text-emerald-650 border border-emerald-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formSuccess}
                  </div>
                )}

                <form onSubmit={handleAdminLoginSubmit} className="space-y-4 text-xs font-bold text-slate-700">
                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                      Administrative Email
                    </label>
                    <input
                      type="email"
                      placeholder="admin@c2c.edu"
                      value={loginEmail}
                      onChange={(e) => setLoginEmail(e.target.value)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 text-xs font-semibold text-slate-800 transition-colors ${
                        loginEmailError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#7C3AED] focus:border-[#7C3AED]'
                      }`}
                      required
                      disabled={formLoading}
                    />
                    {loginEmailError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{loginEmailError}</span>
                    )}
                  </div>

                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                      Security Password
                    </label>
                    <div className="relative">
                      <input
                        type={showPassword ? 'text' : 'password'}
                        placeholder="••••••••••••"
                        value={loginPassword}
                        onChange={(e) => setLoginPassword(e.target.value)}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 pr-10 text-xs font-semibold text-slate-800 transition-colors ${
                          loginPasswordError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#7C3AED] focus:border-[#7C3AED]'
                        }`}
                        required
                        disabled={formLoading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 cursor-pointer"
                      >
                        {showPassword ? <EyeOffIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
                      </button>
                    </div>
                    {loginPasswordError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{loginPasswordError}</span>
                    )}
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading}
                    className={`w-full py-3 bg-[#7C3AED] hover:bg-[#6D28D9] text-white font-bold rounded-xl text-xs cursor-pointer shadow-md shadow-purple-500/20 transition-all flex items-center justify-center gap-2 ${
                      formLoading ? 'opacity-70 cursor-not-allowed' : ''
                    }`}
                  >
                    <span>{formLoading ? 'Authenticating Admin Identity...' : 'Authenticate & Launch Portal'}</span>
                  </button>
                </form>

                <div className="pt-3 border-t border-purple-50 text-center">
                  <p className="text-[10px] text-slate-400 font-medium">
                    {"Unauthorized access attempts are logged under security protocol 2026."}
                  </p>
                </div>
              </div>
            ) : authScreen === 'signup' ? (
              <div className="space-y-6">
                {/* Back button */}
                <button 
                  onClick={() => setAuthScreen('select')}
                  className="flex items-center gap-1.5 text-[10px] font-black uppercase text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                  disabled={formLoading}
                >
                  <ChevronLeftIcon className="w-4 h-4" />
                  <span>Back to Step 1</span>
                </button>

                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">Step 2: Create Your Account ({selectedRole === 'College' ? 'College / Institute' : selectedRole})</h2>
                  <p className="text-xs text-slate-500 mt-1">Let{"'"}s create your {selectedRole.toLowerCase()} account.</p>
                </div>

                {formError && (
                  <div className="bg-red-50 text-red-650 border border-red-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formError}
                  </div>
                )}
                {formSuccess && (
                  <div className="bg-emerald-50 text-emerald-650 border border-emerald-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formSuccess}
                  </div>
                )}

                <form onSubmit={handleSignupSubmit} className="space-y-4 text-xs font-bold text-slate-700">
                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">Full Name</label>
                    <input
                      type="text"
                      placeholder="Enter your full name"
                      value={regFullName}
                      onChange={(e) => setRegFullName(e.target.value)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 text-xs font-semibold text-slate-800 transition-colors ${
                        regFullNameError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                      }`}
                      required
                      disabled={formLoading}
                    />
                    {regFullNameError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{regFullNameError}</span>
                    )}
                  </div>

                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                      {selectedRole === 'Student' ? 'College Email Address' : 
                       selectedRole === 'Mentor' ? 'Corporate Email' : 
                       selectedRole === 'College' ? 'Institutional Email' : 'Corporate Email'}
                    </label>
                    <input
                      type="email"
                      placeholder="username@gmail.com"
                      value={regEmail}
                      onChange={(e) => setRegEmail(e.target.value)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 text-xs font-semibold text-slate-800 transition-colors ${
                        regEmailError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                      }`}
                      required
                      disabled={formLoading}
                    />
                    {regEmailError && (
                      <span className={`text-[10px] font-bold mt-1 font-sans block ${
                        regEmailError.includes('recommended') ? 'text-amber-500' : 'text-red-500'
                      }`}>{regEmailError}</span>
                    )}
                  </div>

                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">Phone Number</label>
                    <input
                      type="text"
                      placeholder="+91 98765 43210"
                      value={regPhone}
                      onChange={(e) => setRegPhone(e.target.value)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 text-xs font-semibold text-slate-800 transition-colors ${
                        regPhoneError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                      }`}
                      required
                      disabled={formLoading}
                    />
                    {regPhoneError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{regPhoneError}</span>
                    )}
                  </div>

                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">Password</label>
                    <div className="relative">
                      <input
                        type={showPassword ? 'text' : 'password'}
                        placeholder="Create a strong password"
                        value={regPassword}
                        onChange={(e) => setRegPassword(e.target.value)}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 pr-10 text-xs font-semibold text-slate-800 transition-colors ${
                          regPasswordError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                        }`}
                        required
                        disabled={formLoading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 cursor-pointer"
                      >
                        {showPassword ? <EyeOffIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
                      </button>
                    </div>
                    {regPasswordError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{regPasswordError}</span>
                    )}
                  </div>

                  <div className="flex items-center gap-2 py-1">
                    <input
                      type="checkbox"
                      id="termsAgree"
                      checked={regTerms}
                      onChange={(e) => setRegTerms(e.target.checked)}
                      className="rounded border-slate-350 text-[#5e17eb] focus:ring-[#5e17eb] w-3.5 h-3.5 cursor-pointer"
                      required
                      disabled={formLoading}
                    />
                    <label htmlFor="termsAgree" className="text-[10px] text-slate-500 font-semibold cursor-pointer">
                      I agree to the <span className="text-[#5e17eb] hover:underline">Terms of Service</span> & <span className="text-[#5e17eb] hover:underline">Privacy Policy</span>
                    </label>
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading}
                    className={`w-full py-2.5 text-white font-bold rounded-xl text-xs cursor-pointer shadow-md transition-all flex items-center justify-center ${
                      formLoading ? 'opacity-70 cursor-not-allowed' : ''
                    } ${
                      selectedRole === 'Student' ? 'bg-[#5e17eb] hover:bg-[#4b12bc]' : 
                      selectedRole === 'Mentor' ? 'bg-emerald-600 hover:bg-emerald-700' : 
                      selectedRole === 'College' ? 'bg-indigo-600 hover:bg-indigo-700' : 'bg-purple-700 hover:bg-purple-800'
                    }`}
                  >
                    {formLoading ? 'Creating Account...' : 'Continue'}
                  </button>

                  <div className="text-center pt-2 text-[10px] text-slate-400 font-bold">
                    <span>Already have an account? </span>
                    <button 
                      type="button"
                      onClick={() => setAuthScreen('login')} 
                      className="text-[#5e17eb] hover:underline font-black cursor-pointer"
                      disabled={formLoading}
                    >
                      Login
                    </button>
                  </div>
                </form>
              </div>
            ) : authScreen === 'login' ? (
              <div className="space-y-6">
                {/* Back button */}
                <button 
                  onClick={() => setAuthScreen('select')}
                  className="flex items-center gap-1.5 text-[10px] font-black uppercase text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                  disabled={formLoading}
                >
                  <ChevronLeftIcon className="w-4 h-4" />
                  <span>Back to Step 1</span>
                </button>

                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">Login as {selectedRole === 'College' ? 'College / Institute' : selectedRole}</h2>
                  <p className="text-xs text-slate-500 mt-1">Welcome back! Please enter your credentials to access your dashboard.</p>
                </div>

                {formError && (
                  <div className="bg-red-50 text-red-650 border border-red-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formError}
                  </div>
                )}
                {formSuccess && (
                  <div className="bg-emerald-50 text-emerald-650 border border-emerald-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formSuccess}
                  </div>
                )}

                <form onSubmit={handleLoginSubmit} className="space-y-4 text-xs font-bold text-slate-700">
                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">
                      {selectedRole === 'Student' ? 'College Email Address' : 
                       selectedRole === 'Mentor' ? 'Corporate Email' : 
                       selectedRole === 'College' ? 'Institutional Email' : 'Corporate Email'}
                    </label>
                    <input
                      type="email"
                      placeholder="username@gmail.com"
                      value={loginEmail}
                      onChange={(e) => setLoginEmail(e.target.value)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 text-xs font-semibold text-slate-800 transition-colors ${
                        loginEmailError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                      }`}
                      required
                      disabled={formLoading}
                    />
                    {loginEmailError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{loginEmailError}</span>
                    )}
                  </div>

                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">Password</label>
                    <div className="relative">
                      <input
                        type={showPassword ? 'text' : 'password'}
                        placeholder="Enter password"
                        value={loginPassword}
                        onChange={(e) => setLoginPassword(e.target.value)}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 pr-10 text-xs font-semibold text-slate-800 transition-colors ${
                          loginPasswordError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                        }`}
                        required
                        disabled={formLoading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 cursor-pointer"
                      >
                        {showPassword ? <EyeOffIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
                      </button>
                    </div>
                    {loginPasswordError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{loginPasswordError}</span>
                    )}
                  </div>

                  <div className="text-right py-1">
                    <button 
                      type="button"
                      onClick={() => setAuthScreen('forgot')}
                      className="text-[10px] font-bold text-slate-400 hover:text-[#5e17eb] transition-colors"
                      disabled={formLoading}
                    >
                      Forgot Password?
                    </button>
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading}
                    className={`w-full py-2.5 text-white font-bold rounded-xl text-xs cursor-pointer shadow-md transition-all flex items-center justify-center ${
                      formLoading ? 'opacity-70 cursor-not-allowed' : ''
                    } ${
                      selectedRole === 'Student' ? 'bg-[#5e17eb] hover:bg-[#4b12bc]' : 
                      selectedRole === 'Mentor' ? 'bg-emerald-600 hover:bg-emerald-700' : 
                      selectedRole === 'College' ? 'bg-indigo-600 hover:bg-indigo-700' : 'bg-purple-700 hover:bg-purple-800'
                    }`}
                  >
                    {formLoading ? 'Signing In...' : `Sign In as ${selectedRole === 'College' ? 'College / Institute' : selectedRole}`}
                  </button>

                  <div className="text-center pt-2 text-[10px] text-slate-400 font-bold">
                    <span>Don{"'"}t have an account yet? </span>
                    <button 
                      type="button"
                      onClick={() => setAuthScreen('signup')} 
                      className="text-[#5e17eb] hover:underline font-black cursor-pointer"
                      disabled={formLoading}
                    >
                      Create Account
                    </button>
                  </div>
                </form>
              </div>
            ) : authScreen === 'forgot' ? (
              <div className="space-y-6">
                {/* Back button */}
                <button 
                  onClick={() => setAuthScreen('login')}
                  className="flex items-center gap-1.5 text-[10px] font-black uppercase text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                  disabled={formLoading}
                >
                  <ChevronLeftIcon className="w-4 h-4" />
                  <span>Back to Login</span>
                </button>

                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">Reset Your Password</h2>
                  <p className="text-xs text-slate-500 mt-1">Enter the verified email address linked with your account and we will dispatch a digital 6-digit verification code.</p>
                </div>

                {formError && (
                  <div className="bg-red-50 text-red-600 border border-red-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formError}
                  </div>
                )}
                {formSuccess && (
                  <div className="bg-emerald-50 text-emerald-600 border border-emerald-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formSuccess}
                  </div>
                )}

                <form onSubmit={handleForgotSubmit} className="space-y-4 text-xs font-bold text-slate-700">
                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">Email Address</label>
                    <input
                      type="email"
                      placeholder="Enter verified email address"
                      value={forgotEmail}
                      onChange={(e) => setForgotEmail(e.target.value)}
                      className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 text-xs font-semibold text-slate-800 transition-colors ${
                        forgotEmailError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                      }`}
                      required
                      disabled={formLoading}
                    />
                    {forgotEmailError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{forgotEmailError}</span>
                    )}
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading}
                    className={`w-full py-2.5 text-white font-bold rounded-xl text-xs cursor-pointer shadow-md transition-all flex items-center justify-center ${
                      formLoading ? 'opacity-70 cursor-not-allowed' : ''
                    } ${
                      selectedRole === 'Student' ? 'bg-[#5e17eb] hover:bg-[#4b12bc]' : 
                      selectedRole === 'Mentor' ? 'bg-emerald-600 hover:bg-emerald-700' : 
                      selectedRole === 'College' ? 'bg-indigo-600 hover:bg-indigo-700' : 'bg-purple-700 hover:bg-purple-800'
                    }`}
                  >
                    {formLoading ? 'Sending Code...' : 'Send Verification Code'}
                  </button>
                </form>
              </div>
            ) : authScreen === 'otp' ? (
              <div className="space-y-6">
                {/* Back button */}
                <button 
                  onClick={() => setAuthScreen('forgot')}
                  className="flex items-center gap-1.5 text-[10px] font-black uppercase text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
                  disabled={formLoading}
                >
                  <ChevronLeftIcon className="w-4 h-4" />
                  <span>Back to Email</span>
                </button>

                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">Security Verification</h2>
                  <p className="text-xs text-slate-500 mt-1">We sent a 6-digit confirmation code to your email. Please type the digits below to authenticate your identity.</p>
                </div>

                {formError && (
                  <div className="bg-red-50 text-red-600 border border-red-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formError}
                  </div>
                )}
                {formSuccess && (
                  <div className="bg-emerald-50 text-emerald-600 border border-emerald-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formSuccess}
                  </div>
                )}

                <form onSubmit={handleOtpVerify} className="space-y-6 text-xs font-bold text-slate-700">
                  
                  {/* OTP 6-Digit Grid */}
                  <div className="flex justify-between items-center gap-2">
                    {otpDigits.map((digit, index) => (
                      <input
                        key={index}
                        id={`otp-input-${index}`}
                        type="text"
                        maxLength={1}
                        value={digit}
                        onChange={(e) => handleOtpChange(index, e.target.value)}
                        onKeyDown={(e) => handleOtpKeyDown(index, e)}
                        className="w-11 h-12 border border-slate-200 rounded-xl text-center text-lg font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#5e17eb] focus:border-[#5e17eb] bg-slate-50 focus:bg-white transition-all"
                        required
                        disabled={formLoading}
                      />
                    ))}
                  </div>

                  {/* Micro actions Area */}
                  <div className="flex justify-between items-center text-[11px] font-bold text-slate-400 px-1">
                    {otpTimer > 0 ? (
                      <span>Resend code in 00:{otpTimer.toString().padStart(2, '0')}</span>
                    ) : (
                      <button
                        type="button"
                        onClick={handleResendCode}
                        className="text-[#5e17eb] hover:underline font-black cursor-pointer"
                        disabled={formLoading}
                      >
                        Resend Code
                      </button>
                    )}
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading}
                    className={`w-full py-2.5 text-white font-bold rounded-xl text-xs cursor-pointer shadow-md transition-all flex items-center justify-center ${
                      formLoading ? 'opacity-70 cursor-not-allowed' : ''
                    } ${
                      selectedRole === 'Student' ? 'bg-[#5e17eb] hover:bg-[#4b12bc]' : 
                      selectedRole === 'Mentor' ? 'bg-emerald-600 hover:bg-emerald-700' : 
                      selectedRole === 'College' ? 'bg-indigo-600 hover:bg-indigo-700' : 'bg-purple-700 hover:bg-purple-800'
                    }`}
                  >
                    {formLoading ? 'Verifying...' : 'Verify & Continue'}
                  </button>
                </form>
              </div>
            ) : (
              <div className="space-y-6">
                <div>
                  <h2 className="text-xl font-extrabold text-slate-900">Create New Password</h2>
                  <p className="text-xs text-slate-500 mt-1">Ensure your new authorization credential contains safe typographic complexities to maximize profile defense.</p>
                </div>

                {formError && (
                  <div className="bg-red-50 text-red-600 border border-red-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formError}
                  </div>
                )}
                {formSuccess && (
                  <div className="bg-emerald-50 text-emerald-600 border border-emerald-200 rounded-xl p-3 text-xs font-bold text-center">
                    {formSuccess}
                  </div>
                )}

                <form onSubmit={handleResetSubmit} className="space-y-4 text-xs font-bold text-slate-700">
                  
                  {/* New Password */}
                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">New Password</label>
                    <div className="relative">
                      <input
                        type={showPassword ? 'text' : 'password'}
                        placeholder="Enter new password"
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 pr-10 text-xs font-semibold text-slate-800 transition-colors ${
                          newPasswordError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                        }`}
                        required
                        disabled={formLoading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 cursor-pointer"
                      >
                        {showPassword ? <EyeOffIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
                      </button>
                    </div>
                    {newPasswordError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{newPasswordError}</span>
                    )}
                  </div>

                  {/* Confirm New Password */}
                  <div className="space-y-1">
                    <label className="block text-[10px] uppercase tracking-wider font-extrabold text-slate-500">Confirm New Password</label>
                    <div className="relative">
                      <input
                        type={showConfirmPassword ? 'text' : 'password'}
                        placeholder="Confirm new password"
                        value={confirmNewPassword}
                        onChange={(e) => setConfirmNewPassword(e.target.value)}
                        className={`w-full px-3.5 py-2.5 border rounded-xl focus:outline-none focus:ring-1 pr-10 text-xs font-semibold text-slate-800 transition-colors ${
                          confirmNewPasswordError ? 'border-red-500 focus:ring-red-500 focus:border-red-500' : 'border-slate-200 focus:ring-[#5e17eb] focus:border-[#5e17eb]'
                        }`}
                        required
                        disabled={formLoading}
                      />
                      <button
                        type="button"
                        onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                        className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 cursor-pointer"
                      >
                        {showConfirmPassword ? <EyeOffIcon className="w-4 h-4" /> : <EyeIcon className="w-4 h-4" />}
                      </button>
                    </div>
                    {confirmNewPasswordError && (
                      <span className="text-red-500 text-[10px] font-bold mt-1 font-sans block">{confirmNewPasswordError}</span>
                    )}
                  </div>

                  <button
                    type="submit"
                    disabled={formLoading}
                    className={`w-full py-2.5 text-white font-bold rounded-xl text-xs cursor-pointer shadow-md transition-all flex items-center justify-center ${
                      formLoading ? 'opacity-70 cursor-not-allowed' : ''
                    } ${
                      selectedRole === 'Student' ? 'bg-[#5e17eb] hover:bg-[#4b12bc]' : 
                      selectedRole === 'Mentor' ? 'bg-emerald-600 hover:bg-emerald-700' : 
                      selectedRole === 'College' ? 'bg-indigo-600 hover:bg-indigo-700' : 'bg-purple-700 hover:bg-purple-800'
                    }`}
                  >
                    {formLoading ? 'Updating Password...' : 'Update Password & Sign In'}
                  </button>
                </form>
              </div>
            )}

          </div>
        </div>
      )}

    </div>
  );
};