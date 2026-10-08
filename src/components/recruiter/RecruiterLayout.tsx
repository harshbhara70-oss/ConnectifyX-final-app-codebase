import { useState, useEffect } from "react";
import RecruiterNavbar from "./RecruiterNavbar";
import RecruiterSidebar from "./RecruiterSidebar";
import { 
  ShieldAlert, 
  Clock, 
  CheckCircle2, 
  Building2, 
  FileText, 
  ArrowRight,
  ShieldCheck,
  RefreshCw,
  Lock
} from "lucide-react";
import { useLocation, useNavigate } from "react-router-dom";

interface RecruiterLayoutProps {
  children: React.ReactNode;
  title?: string;
  subtitle?: string;
  sidebarHighlight?: string;
}

export type VerificationStatus = "UNFILLED" | "PENDING" | "VERIFIED";

const RecruiterLayout = ({ children, title, subtitle, sidebarHighlight }: RecruiterLayoutProps) => {
  const navigate = useNavigate();
  const location = useLocation();

  const [status, setStatus] = useState<VerificationStatus>("UNFILLED");
  const [profile, setProfile] = useState<any>(null);

  // Load verification status from localStorage
  const loadStatus = () => {
    try {
      const storedStatus = localStorage.getItem("c2c_verification_status") as VerificationStatus;
      const storedProfile = localStorage.getItem("c2c_company_profile");
      
      if (storedProfile) {
        setProfile(JSON.parse(storedProfile));
      }
      
      if (storedStatus) {
        setStatus(storedStatus);
      } else {
        setStatus("UNFILLED");
      }
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    loadStatus();
    // Listen for storage and custom status updates
    window.addEventListener("storage", loadStatus);
    window.addEventListener("c2c-status-change", loadStatus);
    return () => {
      window.removeEventListener("storage", loadStatus);
      window.removeEventListener("c2c-status-change", loadStatus);
    };
  }, [location.pathname]);

  // Admin Demo Action: Verify Company Profile
  const handleAdminApprove = () => {
    localStorage.setItem("c2c_verification_status", "VERIFIED");
    setStatus("VERIFIED");
  };

  // Admin Demo Action: Reset to Pending
  const handleResetPending = () => {
    localStorage.setItem("c2c_verification_status", "PENDING");
    setStatus("PENDING");
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <div className="flex min-h-screen">
        <RecruiterSidebar highlight={sidebarHighlight} />
        <div className="flex min-w-0 flex-1 flex-col">
          <RecruiterNavbar title={title} subtitle={subtitle} />

          <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8" style={{ animation: "c2c-fade-up 320ms ease both" }}>
            
            {/* STEP 1: UNFILLED STATUS — Prompt to fill out Company Profile */}
            {status === "UNFILLED" && location.pathname !== "/recruiter/settings" && (
              <div className="mb-6 p-5 bg-amber-50 border-2 border-amber-300 rounded-2xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-sm">
                <div className="flex items-start gap-3">
                  <div className="p-2.5 bg-amber-100 text-amber-700 rounded-xl shrink-0">
                    <Lock className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-amber-900">Company Verification Required</h3>
                    <p className="text-xs text-amber-700 mt-0.5 max-w-xl">
                      You must complete your company profile details and submit for Admin Verification before accessing candidate data, job posting, and pipeline tools.
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => navigate("/recruiter/settings")}
                  className="inline-flex items-center gap-2 px-4 py-2 bg-amber-600 hover:bg-amber-700 text-white text-xs font-bold rounded-xl transition-all shadow-sm shrink-0"
                >
                  Complete Company Profile <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            )}

            {/* STEP 2: PENDING STATUS — Restricted View except Settings and Notifications */}
            {status === "PENDING" && location.pathname !== "/recruiter/settings" && location.pathname !== "/recruiter/messages" ? (
              <div className="max-w-2xl mx-auto my-8 space-y-6">
                <div className="bg-white rounded-3xl p-8 border border-amber-200 shadow-xl text-center space-y-6 relative overflow-hidden">
                  <div className="absolute top-0 left-0 right-0 h-2 bg-gradient-to-r from-amber-400 via-orange-500 to-amber-400"></div>

                  <div className="w-20 h-20 rounded-3xl bg-amber-50 border border-amber-200 flex items-center justify-center text-amber-600 mx-auto shadow-inner">
                    <Clock className="w-10 h-10 animate-pulse" />
                  </div>

                  <div>
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-extrabold bg-amber-100 text-amber-800 border border-amber-300">
                      ⏳ PENDING ADMIN VERIFICATION
                    </span>
                    <h2 className="text-2xl font-extrabold text-slate-900 mt-3">Company Profile Under Admin Review</h2>
                    <p className="text-slate-600 text-sm mt-2 leading-relaxed max-w-md mx-auto">
                      Your company details have been submitted. An administrator is currently reviewing your credentials. You can access Settings and Notifications while review is in progress.
                    </p>
                  </div>

                  {/* Submitted Profile Card Summary */}
                  {profile && (
                    <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 text-left space-y-2 text-xs">
                      <p className="font-bold text-slate-500 uppercase tracking-wider text-[10px]">Submitted Credentials</p>
                      <div className="grid grid-cols-2 gap-2 text-slate-700 font-semibold">
                        <div>Company: <span className="text-slate-900 font-bold">{profile.companyName || "N/A"}</span></div>
                        <div>Representative: <span className="text-slate-900 font-bold">{profile.repName || "N/A"}</span></div>
                        <div>Website: <span className="text-slate-900 font-bold">{profile.websiteUrl || "N/A"}</span></div>
                        <div>Submitted: <span className="text-slate-900 font-bold">{profile.submittedAt || "Recently"}</span></div>
                      </div>
                    </div>
                  )}

                  <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
                    <button
                      onClick={() => navigate("/recruiter/messages")}
                      className="px-4 py-2 bg-amber-50 hover:bg-amber-100 text-amber-800 border border-amber-300 text-xs font-bold rounded-xl transition-all shadow-xs"
                    >
                      View Notifications & Messages
                    </button>
                    <button
                      onClick={() => navigate("/recruiter/settings")}
                      className="px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold rounded-xl transition-all shadow-xs"
                    >
                      View Company Profile
                    </button>
                  </div>
                </div>
              </div>
            ) : status === "UNFILLED" && location.pathname !== "/recruiter/settings" && location.pathname !== "/recruiter/messages" ? (
              /* UNFILLED Lockout View when trying to view other pages */
              <div className="max-w-xl mx-auto my-12 bg-white rounded-3xl p-8 border border-slate-200 shadow-xl text-center space-y-5">
                <div className="w-16 h-16 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-600 mx-auto border border-amber-200">
                  <Lock className="w-8 h-8" />
                </div>
                <h2 className="text-xl font-bold text-slate-900">Company Verification Required</h2>
                <p className="text-slate-500 text-sm leading-relaxed">
                  You must complete your Company Profile in Settings and submit for Admin Verification before using recruiter candidate tools. You can view your notifications while unverified.
                </p>
                <div className="flex flex-wrap items-center justify-center gap-3">
                  <button
                    onClick={() => navigate("/recruiter/settings")}
                    className="px-5 py-2.5 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl shadow-md inline-flex items-center gap-2"
                  >
                    Go to Company Settings <ArrowRight className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => navigate("/recruiter/messages")}
                    className="px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold rounded-xl transition-all"
                  >
                    Check Notifications
                  </button>
                </div>
              </div>
            ) : (
              /* VERIFIED or ON SETTINGS PAGE — Render page content */
              <div>
                {children}
              </div>
            )}
          </main>

          {/* Footer */}
          <footer className="border-t px-6 py-4 flex flex-wrap items-center justify-between gap-4 text-xs text-slate-400"
            style={{ borderColor: "var(--c2c-border)" }}
          >
            <div className="flex items-center gap-4">
              <span className="font-bold text-slate-600">C2C</span>
              <span>© 2026 C2C. All rights reserved.</span>
            </div>
            <div className="flex items-center gap-4">
              <a href="#" className="hover:text-slate-600 transition-colors">Privacy Policy</a>
              <a href="#" className="hover:text-slate-600 transition-colors">Terms of Service</a>
              <a href="#" className="hover:text-slate-600 transition-colors">Cookie Settings</a>
              <a href="#" className="hover:text-slate-600 transition-colors">Contact Support</a>
            </div>
          </footer>
        </div>
      </div>
    </div>
  );
};

export default RecruiterLayout;
