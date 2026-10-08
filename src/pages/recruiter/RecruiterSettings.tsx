import { useState, useEffect, useRef } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import RecruiterLayout from "../../components/recruiter/RecruiterLayout";
import {
  ShieldCheck,
  Upload,
  CheckCircle2,
  Lock,
  AlertTriangle,
  Send,
  Building,
  Globe,
  UserCheck,
  Image as ImageIcon
} from "lucide-react";
import { cn } from "../../lib/utils";

const RecruiterSettings = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const tabParam = searchParams.get("tab");
  const [activeTab, setActiveTab] = useState(tabParam || "company");

  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (tabParam) {
      setActiveTab(tabParam);
    }
  }, [tabParam]);

  // Form State
  const [companyName, setCompanyName] = useState("");
  const [websiteUrl, setWebsiteUrl] = useState("");
  const [aboutCompany, setAboutCompany] = useState("");
  const [repName, setRepName] = useState("");
  const [logoUrl, setLogoUrl] = useState<string | null>(null);
  
  const [repNameError, setRepNameError] = useState("");
  const [savedSuccess, setSavedSuccess] = useState(false);
  const [editRequestSent, setEditRequestSent] = useState(false);
  const [isVerified, setIsVerified] = useState(false);

  // Load profile and verification status on mount & storage changes
  const loadProfileAndStatus = () => {
    try {
      const status = localStorage.getItem("c2c_verification_status") || "UNFILLED";
      const profileStr = localStorage.getItem("c2c_company_profile");
      
      const verified = status === "VERIFIED";
      setIsVerified(verified);

      if (profileStr) {
        const p = JSON.parse(profileStr);
        setRepName(p.repName || "");
        setCompanyName(p.companyName || "");
        setWebsiteUrl(p.websiteUrl || "");
        setAboutCompany(p.aboutCompany || "");
        setLogoUrl(p.logoUrl || null);
      } else if (verified) {
        // Fallback default verified profile data if no custom profile saved
        setRepName("Alexander Wright");
        setCompanyName("Lumina Nexus Tech");
        setWebsiteUrl("https://luminanexus.com");
        setAboutCompany("Enterprise AI software and campus recruitment platform partner.");
        setLogoUrl("https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=200&q=80");
      } else {
        // Reset form to blank for unverified / unfilled onboarding state
        setRepName("");
        setCompanyName("");
        setWebsiteUrl("");
        setAboutCompany("");
        setLogoUrl(null);
      }
    } catch (e) {
      console.error(e);
    }
  };

  useEffect(() => {
    loadProfileAndStatus();
    window.addEventListener("storage", loadProfileAndStatus);
    return () => window.removeEventListener("storage", loadProfileAndStatus);
  }, []);

  // Representative Name: No Numbers rule
  const handleRepNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (isVerified) return;
    const raw = e.target.value;
    if (/[0-9]/.test(raw)) {
      setRepNameError("Numbers are not allowed in Name field");
    } else {
      setRepNameError("");
    }
    setRepName(raw.replace(/[0-9]/g, ""));
  };

  // Logo file upload handler
  const handleLogoSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setLogoUrl(reader.result as string);
        setErrors(prev => ({ ...prev, logo: "" }));
      };
      reader.readAsDataURL(file);
    }
  };

  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSave = () => {
    if (isVerified) {
      // Request edit from Admin
      setEditRequestSent(true);
      const notif = {
        id: Date.now(),
        text: `Company ${companyName || "Partner"} requested an edit to verified profile details.`,
        time: "Just now"
      };
      try {
        const existing = JSON.parse(localStorage.getItem("c2c_admin_notifications") || "[]");
        localStorage.setItem("c2c_admin_notifications", JSON.stringify([notif, ...existing]));
        window.dispatchEvent(new Event("storage"));
      } catch (e) {
        console.error(e);
      }
      setTimeout(() => setEditRequestSent(false), 4000);
      return;
    }

    const newErrors: Record<string, string> = {};
    if (!logoUrl) newErrors.logo = "Company Logo is mandatory for admin verification";
    if (!repName.trim()) newErrors.repName = "Representative Name is required";
    if (!companyName.trim()) newErrors.companyName = "Company Name is required";
    if (!websiteUrl.trim()) newErrors.websiteUrl = "Website URL is required";
    if (!aboutCompany.trim()) newErrors.aboutCompany = "About Company is required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    setErrors({});
    const profileData = {
      repName: repName.trim(),
      companyName: companyName.trim(),
      websiteUrl: websiteUrl.trim(),
      aboutCompany: aboutCompany.trim(),
      logoUrl: logoUrl,
      submittedAt: new Date().toLocaleDateString("en-US", { month: "short", day: "2-digit", year: "numeric" })
    };

    localStorage.setItem("c2c_company_profile", JSON.stringify(profileData));
    localStorage.setItem("c2c_verification_status", "PENDING");

    // Push notification to Admin
    const adminNotif = {
      id: Date.now(),
      text: `New Verification Request: ${companyName.trim()} submitted by ${repName.trim()}`,
      time: "Just now"
    };
    try {
      const existing = JSON.parse(localStorage.getItem("c2c_admin_notifications") || "[]");
      localStorage.setItem("c2c_admin_notifications", JSON.stringify([adminNotif, ...existing]));
    } catch (e) {
      console.error(e);
    }

    window.dispatchEvent(new Event("storage"));
    setSavedSuccess(true);
    setTimeout(() => {
      setSavedSuccess(false);
      navigate("/recruiter/dashboard");
    }, 1500);
  };

  const tabs = [
    { id: "company", label: "Company Profile" },
    { id: "team", label: "Team Management" },
    { id: "notifications", label: "Notifications & Security" }
  ];

  return (
    <RecruiterLayout
      title="Company Settings"
      subtitle="Manage corporate branding, verification details, and account preferences."
      sidebarHighlight="/recruiter/settings"
    >
      <div className="max-w-5xl mx-auto space-y-6 pb-12">
        {/* Hidden File Input for Logo */}
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          className="hidden"
          onChange={handleLogoSelect}
        />

        {/* Header Tabs */}
        <div className="flex space-x-8 border-b border-[var(--c2c-border)]">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={cn(
                "pb-3 text-sm font-medium transition-colors relative",
                activeTab === tab.id
                  ? "text-[var(--c2c-primary)] font-bold"
                  : "text-[var(--c2c-muted)] hover:text-[var(--c2c-text)]"
              )}
            >
              {tab.label}
              {activeTab === tab.id && (
                <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[var(--c2c-primary)] rounded-t-full" />
              )}
            </button>
          ))}
        </div>

        {!isVerified && (
          <div className="p-5 bg-gradient-to-r from-amber-500/10 via-purple-500/10 to-amber-500/10 border-2 border-amber-300 rounded-2xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 shadow-xs">
            <div className="flex items-start gap-3">
              <div className="p-2.5 bg-amber-100 text-amber-800 rounded-xl shrink-0">
                <Building className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-amber-900">New Recruiter Onboarding — Company Verification</h3>
                <p className="text-xs text-amber-800 mt-0.5 max-w-2xl leading-relaxed">
                  Fill in your corporate credentials and upload your mandatory company logo below to submit your verification request to Admin.
                </p>
              </div>
            </div>
          </div>
        )}

        {savedSuccess && (
          <div className="p-4 bg-emerald-50 border border-emerald-200 rounded-2xl flex items-center gap-3 text-emerald-800 text-sm font-semibold">
            <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
            Company profile created & submitted for Admin Verification! Redirecting...
          </div>
        )}

        {editRequestSent && (
          <div className="p-4 bg-blue-50 border border-blue-200 rounded-2xl flex items-center gap-3 text-blue-800 text-sm font-semibold">
            <Send className="w-5 h-5 text-blue-600 shrink-0" />
            Edit request sent to Admin notification panel! Admin will review your field change request.
          </div>
        )}

        {/* Tab Content */}
        <div className="pt-2">
          {/* COMPANY PROFILE TAB */}
          {activeTab === "company" && (
            <div className="flex flex-col gap-6">
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Left Column */}
                <div className="lg:col-span-2 space-y-6">
                  <div className="bg-white rounded-2xl p-6 border border-[var(--c2c-border)] shadow-xs hover:shadow-md transition-shadow">
                    <div className="flex items-center justify-between mb-6">
                      <h3 className="text-lg font-bold text-[var(--c2c-text)]">
                        Corporate Identity
                      </h3>
                      {isVerified ? (
                        <span className="inline-flex items-center gap-1 text-xs font-bold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200">
                          <Lock className="w-3.5 h-3.5 text-emerald-600" /> LOCKED BY ADMIN (VERIFIED)
                        </span>
                      ) : (
                        <span className="text-xs text-[var(--c2c-muted)]"><span className="text-rose-500 font-bold">*</span> Mandatory fields</span>
                      )}
                    </div>

                    {/* Mandatory Company Logo Upload */}
                    <div className="mb-6">
                      <label className="block text-xs font-semibold text-[var(--c2c-text)] mb-2">
                        Company Logo {!isVerified && <span className="text-rose-500 font-bold">*</span>}
                      </label>
                      <div className={cn(
                        "flex items-center gap-6 p-4 rounded-xl border transition-all",
                        errors.logo ? "bg-rose-50/60 border-rose-300" : "bg-slate-50 border-slate-200"
                      )}>
                        {logoUrl ? (
                          <img 
                            src={logoUrl} 
                            alt="Company Logo" 
                            className="h-20 w-20 rounded-2xl object-cover border border-slate-300 shadow-sm"
                          />
                        ) : (
                          <div className="h-20 w-20 rounded-2xl bg-[var(--c2c-primary)] text-white flex items-center justify-center text-3xl font-bold shadow-md">
                            {companyName ? companyName[0].toUpperCase() : "L"}
                          </div>
                        )}
                        <div>
                          <button 
                            type="button" 
                            onClick={() => fileInputRef.current?.click()}
                            className="flex items-center gap-2 px-4 py-2 border border-[#5e17eb] rounded-xl text-xs font-bold text-white bg-[#5e17eb] hover:bg-[#4b12bc] transition-colors shadow-xs"
                          >
                            <Upload className="h-4 w-4" />
                            {logoUrl ? "Change Logo" : "Upload Mandatory Logo *"}
                          </button>
                          <p className="text-[11px] text-slate-500 mt-1.5 font-medium">
                            Logo upload is mandatory for admin review (PNG/SVG, max 2MB).
                          </p>
                          {errors.logo && (
                            <p className="text-xs text-rose-600 font-bold flex items-center gap-1 mt-1.5">
                              <AlertTriangle className="w-3.5 h-3.5" /> {errors.logo}
                            </p>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Inputs */}
                    <div className="space-y-4">
                      <div>
                        <div className="flex items-center justify-between mb-1">
                          <label className="block text-xs font-semibold text-[var(--c2c-text)]">
                            Company Representative Name {!isVerified && <span className="text-rose-500">*</span>}
                          </label>
                          {isVerified && <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-1"><Lock className="w-3 h-3" /> Locked</span>}
                        </div>
                        <input
                          type="text"
                          value={repName}
                          disabled={isVerified}
                          onChange={handleRepNameChange}
                          placeholder="FullName (Letters only)"
                          className={cn(
                            "w-full px-4 py-2.5 rounded-xl border text-sm font-medium transition-all",
                            isVerified 
                              ? "bg-slate-100/80 text-slate-600 border-slate-200 cursor-not-allowed" 
                              : "border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-slate-800"
                          )}
                        />
                        {repNameError && (
                          <p className="mt-1 text-xs text-rose-600 font-bold flex items-center gap-1">
                            <AlertTriangle className="w-3.5 h-3.5" /> {repNameError}
                          </p>
                        )}
                        {errors.repName && (
                          <p className="mt-1 text-xs text-rose-600 font-semibold flex items-center gap-1">
                            <AlertTriangle className="w-3.5 h-3.5" /> {errors.repName}
                          </p>
                        )}
                      </div>

                      <div>
                        <div className="flex items-center justify-between mb-1">
                          <label className="block text-xs font-semibold text-[var(--c2c-text)]">
                            Company / Legal Entity Name {!isVerified && <span className="text-rose-500">*</span>}
                          </label>
                          {isVerified && <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-1"><Lock className="w-3 h-3" /> Locked</span>}
                        </div>
                        <input
                          type="text"
                          value={companyName}
                          disabled={isVerified}
                          onChange={(e) => setCompanyName(e.target.value)}
                          placeholder="e.g. Lumina Nexus Tech Solutions"
                          className={cn(
                            "w-full px-4 py-2.5 rounded-xl border text-sm font-medium transition-all",
                            isVerified 
                              ? "bg-slate-100/80 text-slate-600 border-slate-200 cursor-not-allowed" 
                              : "border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-slate-800"
                          )}
                        />
                        {errors.companyName && (
                          <p className="mt-1 text-xs text-rose-600 font-semibold flex items-center gap-1">
                            <AlertTriangle className="w-3.5 h-3.5" /> {errors.companyName}
                          </p>
                        )}
                      </div>

                      <div>
                        <div className="flex items-center justify-between mb-1">
                          <label className="block text-xs font-semibold text-[var(--c2c-text)]">
                            Official Website URL {!isVerified && <span className="text-rose-500">*</span>}
                          </label>
                          {isVerified && <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-1"><Lock className="w-3 h-3" /> Locked</span>}
                        </div>
                        <input
                          type="url"
                          value={websiteUrl}
                          disabled={isVerified}
                          onChange={(e) => setWebsiteUrl(e.target.value)}
                          placeholder="https://company.com"
                          className={cn(
                            "w-full px-4 py-2.5 rounded-xl border text-sm font-medium transition-all",
                            isVerified 
                              ? "bg-slate-100/80 text-slate-600 border-slate-200 cursor-not-allowed" 
                              : "border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-slate-800"
                          )}
                        />
                        {errors.websiteUrl && (
                          <p className="mt-1 text-xs text-rose-600 font-semibold flex items-center gap-1">
                            <AlertTriangle className="w-3.5 h-3.5" /> {errors.websiteUrl}
                          </p>
                        )}
                      </div>

                      <div>
                        <div className="flex items-center justify-between mb-1">
                          <label className="block text-xs font-semibold text-[var(--c2c-text)]">
                            About Company {!isVerified && <span className="text-rose-500">*</span>}
                          </label>
                          {isVerified && <span className="text-[10px] text-emerald-700 font-bold flex items-center gap-1"><Lock className="w-3 h-3" /> Locked</span>}
                        </div>
                        <textarea
                          rows={4}
                          value={aboutCompany}
                          disabled={isVerified}
                          onChange={(e) => setAboutCompany(e.target.value)}
                          placeholder="Describe company operations, culture, and recruitment goals..."
                          className={cn(
                            "w-full px-4 py-2.5 rounded-xl border text-sm font-medium transition-all resize-none",
                            isVerified 
                              ? "bg-slate-100/80 text-slate-600 border-slate-200 cursor-not-allowed" 
                              : "border-[var(--c2c-border-strong)] focus:outline-none focus:ring-2 focus:ring-[var(--c2c-primary)]/20 text-slate-800"
                          )}
                        />
                        {errors.aboutCompany && (
                          <p className="mt-1 text-xs text-rose-600 font-semibold flex items-center gap-1">
                            <AlertTriangle className="w-3.5 h-3.5" /> {errors.aboutCompany}
                          </p>
                        )}
                      </div>
                    </div>

                    {/* Action Button */}
                    <div className="mt-8 flex justify-end border-t border-[var(--c2c-border)] pt-4">
                      <button
                        type="button"
                        onClick={handleSave}
                        className={cn(
                          "px-6 py-2.5 rounded-xl font-bold text-sm transition-all shadow-md flex items-center gap-2",
                          isVerified
                            ? "bg-amber-500 hover:bg-amber-600 text-white"
                            : "bg-[var(--c2c-primary)] hover:bg-[#4b12bc] text-white"
                        )}
                      >
                        {isVerified ? (
                          <>
                            <Send className="w-4 h-4" />
                            Request Admin Profile Edit
                          </>
                        ) : (
                          <>
                            <ShieldCheck className="w-4 h-4" />
                            Submit Corporate Profile for Admin Verification
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                </div>

                {/* Right Verification Status Column */}
                <div className="space-y-6">
                  <div className="bg-white rounded-2xl p-6 border border-[var(--c2c-border)] shadow-xs">
                    <h4 className="text-sm font-bold text-[var(--c2c-text)] mb-3">
                      Verification Badge Status
                    </h4>
                    {isVerified ? (
                      <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-900 space-y-2">
                        <div className="flex items-center gap-2">
                          <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                          <span className="font-extrabold text-sm">Verified Corporate Account</span>
                        </div>
                        <p className="text-xs text-emerald-800 leading-relaxed">
                          Your company details are verified by Campus2Corporate Admin. Core profile fields are locked for security compliance.
                        </p>
                      </div>
                    ) : (
                      <div className="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 space-y-2">
                        <div className="flex items-center gap-2">
                          <AlertTriangle className="w-5 h-5 text-amber-600" />
                          <span className="font-extrabold text-sm">Unverified Account</span>
                        </div>
                        <p className="text-xs text-amber-800 leading-relaxed">
                          Upload mandatory logo and complete your company profile to submit a verification request to Admin.
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TEAM MANAGEMENT TAB */}
          {activeTab === "team" && (
            <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs space-y-6">
              <div className="flex items-center justify-between border-b border-slate-100 pb-4">
                <div>
                  <h3 className="text-base font-bold text-slate-900">Recruitment Team Members</h3>
                  <p className="text-xs text-slate-500 mt-0.5">Manage recruiters and hiring managers who have access to candidate pipelines.</p>
                </div>
                <button className="px-4 py-2 bg-[#5e17eb] hover:bg-[#4b12bc] text-white text-xs font-bold rounded-xl shadow-xs">
                  + Invite Team Member
                </button>
              </div>

              <div className="divide-y divide-slate-100">
                <div className="py-3 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-[#5e17eb] text-white font-bold flex items-center justify-center text-xs">
                      AW
                    </div>
                    <div>
                      <p className="text-xs font-bold text-slate-900">Alexander Wright (You)</p>
                      <p className="text-[11px] text-slate-400">alexander@luminanexus.com</p>
                    </div>
                  </div>
                  <span className="px-2.5 py-0.5 bg-purple-50 text-[#5e17eb] text-[10px] font-bold rounded-full">
                    Account Owner / Admin
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* NOTIFICATIONS TAB */}
          {activeTab === "notifications" && (
            <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs space-y-4">
              <h3 className="text-base font-bold text-slate-900">Notification Preferences</h3>
              <p className="text-xs text-slate-500">Configure email & dashboard alerts for candidate applications and interview updates.</p>
              <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-700 font-medium">
                Email alerts for new applications are enabled by default.
              </div>
            </div>
          )}
        </div>
      </div>
    </RecruiterLayout>
  );
};

export default RecruiterSettings;
