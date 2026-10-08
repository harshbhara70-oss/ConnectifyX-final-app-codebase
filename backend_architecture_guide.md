# Campus2Corporate - Complete Backend Architecture & Database Blueprint

Iss document me **Campus2Corporate** web application ka complete Backend Structure, Database Design, Collections (Tables), API Endpoints aur Step-by-Step Backend Setup instructions diye gaye hain.

---

## 🛠️ 1. Tech Stack Overview

| Layer | Technology | Description |
| :--- | :--- | :--- |
| **Runtime Environment** | Node.js (v18+) | JavaScript runtime for server side |
| **Framework** | Express.js | Fast REST API framework |
| **Database** | MongoDB (Atlas / Local) | NoSQL document database |
| **ODM / ORM** | Mongoose | Schema validation & DB query builder |
| **Authentication** | JWT (JSON Web Tokens) & bcryptjs | Password hashing & role-based authentication |
| **File Storage** | Cloudinary / Local Multer | Resume & profile photo uploads |

---

## 📁 2. Backend Folder Structure

Workspace me backend code `server/` directory ke andar structured hai:

```
Campus2Corporate/
├── .env                       # Environment Variables (DB URI, PORT, JWT Secret)
├── server/
│   ├── server.js              # Entry Point (Express App, DB connection, Routes)
│   ├── config/
│   │   └── db.js              # MongoDB Atlas Mongoose connection logic
│   ├── models/                # Database Schemas (Collections)
│   │   ├── User.js            # Base Auth Model (Roles: student, college, recruiter, admin, mentor)
│   │   ├── StudentProfile.js  # Student details, skills, progress, placement status
│   │   ├── CollegeProfile.js  # College details, AISHE code, accreditation
│   │   ├── StaffMember.js     # TPO officers & HOD admins management
│   │   ├── JobDrive.js        # Corporate campus drives, roles, package LPA
│   │   ├── Application.js    # Student drive applications & interview stages
│   │   ├── Assessment.js     # Skill tests & diagnostic scores
│   │   └── Company.js         # Recruiter profiles & corporate details
│   ├── controllers/           # Business Logic for API handlers
│   │   ├── authController.js
│   │   ├── collegeController.js
│   │   ├── studentController.js
│   │   ├── driveController.js
│   │   └── reportController.js
│   ├── middleware/            # JWT Auth & Role Authorization
│   │   ├── authMiddleware.js  # Verify JWT token
│   │   └── roleMiddleware.js  # Restrict routes by role (college/student/recruiter)
│   ├── routes/                # Express Router Endpoints
│   │   ├── authRoutes.js
│   │   ├── collegeRoutes.js
│   │   ├── studentRoutes.js
│   │   └── driveRoutes.js
│   └── utils/                 # Helper Functions & Exporters
│       ├── generateToken.js
│       └── csvExporter.js
```

---

## 🗄️ 3. Database Collections (Tables) Breakdown

Platform ke 8 core internal portals ko run karne ke liye total **8-9 Primary Collections (Tables)** use hongi:

```mermaid
erDiagram
    USER ||--o{ STUDENT_PROFILE : "has profile"
    USER ||--o{ COLLEGE_PROFILE : "manages"
    COLLEGE_PROFILE ||--o{ STAFF_MEMBER : "employs"
    COLLEGE_PROFILE ||--o{ STUDENT_PROFILE : "enrolls"
    COMPANY ||--o{ JOB_DRIVE : "posts"
    JOB_DRIVE ||--o{ APPLICATION : "receives"
    STUDENT_PROFILE ||--o{ APPLICATION : "applies"
    STUDENT_PROFILE ||--o{ ASSESSMENT : "completes"
```

### Collection Schemas & Fields Details:

#### 1. `users` (Authentication & Access Control)
* **`_id`**: ObjectId
* **`email`**: String (Unique, Required)
* **`password`**: String (Hashed with bcryptjs)
* **`role`**: String (`'student'`, `'college'`, `'recruiter'`, `'admin'`, `'mentor'`)
* **`isVerified`**: Boolean (Default: `false`)
* **`createdAt`**: Date

#### 2. `college_profiles` (College Registration & Verification)
* **`_id`**: ObjectId
* **`userId`**: Ref -> `User`
* **`collegeName`**: String ("Apex Institute of Technology")
* **`aisheCode`**: String ("C-41209")
* **`accreditation`**: String ("NAAC A+", "NBA")
* **`verificationStatus`**: String (`'Pending'`, `'Admin Approved'`, `'Rejected'`)
* **`contactEmail`**: String
* **`phone`**: String

#### 3. `staff_members` (Authorized Staff & HOD Governance)
* **`_id`**: ObjectId
* **`collegeId`**: Ref -> `CollegeProfile`
* **`name`**: String ("Dr. Sarah Jenkins")
* **`designation`**: String ("Head of TPO")
* **`role`**: String (`'TPO Officer'`, `'HOD Admin'`, `'System Admin'`)
* **`department`**: String ("Computer Science")
* **`accessLevel`**: String (`'Full Access'`, `'Department Level'`, `'Read Only'`)
* **`status`**: String (`'Active'`, `'Pending Approval'`)

#### 4. `student_profiles` (Student Monitoring & Progress)
* **`_id`**: ObjectId
* **`userId`**: Ref -> `User`
* **`collegeId`**: Ref -> `CollegeProfile`
* **`name`**: String ("Rahul Sharma")
* **`rollNo`**: String ("2021-CSE-042")
* **`department`**: String ("Computer Science")
* **`semester`**: Number (1-8)
* **`skills`**: Array of Strings `["Java", "DSA", "React"]`
* **`learningProgress`**: Number (0-100)
* **`avgAssessmentScore`**: Number (0-100)
* **`overallSkillScore`**: Number (0-100)
* **`placementStatus`**: String (`'Placed'`, `'Eligible & Ready'`, `'In Pipeline'`, `'Needs Improvement'`)
* **`assessmentsCompleted`**: Boolean
* **`profileCompleted`**: Boolean
* **`resumeVerified`**: Boolean
* **`isReleasedToRecruiters`**: Boolean (Eligibility Gateway toggle)

#### 5. `job_drives` (Recruiter Activity & Placement Tracking)
* **`_id`**: ObjectId
* **`companyName`**: String ("Google India")
* **`role`**: String ("Software Development Engineer")
* **`packageLPA`**: String ("44.5 LPA")
* **`branchesAllowed`**: Array of Strings `["CS", "IT", "ECE"]`
* **`minSkillScoreRequired`**: Number (Default: 70)
* **`driveDate`**: Date
* **`status`**: String (`'Upcoming Drive'`, `'Live Interviewing'`, `'Completed'`, `'Pending Release'`)
* **`shortlistedCandidates`**: Array of Refs -> `StudentProfile`

#### 6. `applications` (Candidate Pipeline Status)
* **`_id`**: ObjectId
* **`driveId`**: Ref -> `JobDrive`
* **`studentId`**: Ref -> `StudentProfile`
* **`stage`**: String (`'Applied'`, `'Aptitude Passed'`, `'Tech Round 1'`, `'HR Round'`, `'Offer Released'`)
* **`status`**: String (`'Under Review'`, `'Shortlisted'`, `'Rejected'`, `'Hired'`)

#### 7. `assessments` (Diagnostic & Skill Analytics)
* **`_id`**: ObjectId
* **`studentId`**: Ref -> `StudentProfile`
* **`title`**: String ("Data Structures Diagnostic")
* **`score`**: Number
* **`maxScore`**: Number
* **`percentile`**: Number
* **`aiStrengths`**: Array of Strings
* **`aiWeaknesses`**: Array of Strings

---

## 🌐 4. Complete REST API Endpoints

### 🔐 Auth Routes (`/api/auth`)
* `POST /api/auth/register` - Naya account register karein (Role: student/college/recruiter)
* `POST /api/auth/login` - User login karein & JWT token payein
* `GET /api/auth/me` - Logged in user detail (Protected route)

### 🏛️ College Dashboard Routes (`/api/college`)
* `GET /api/college/overview` - Profile status & verification summary
* `GET /api/college/staff` - Authorized staff & department list
* `POST /api/college/staff` - Add new TPO officer / HOD admin member
* `DELETE /api/college/staff/:id` - Revoke staff access
* `GET /api/college/students` - Student directory search, filter, and pagination
* `GET /api/college/students/:id` - Individual student drill-down progress analytics
* `GET /api/college/eligible-gateway` - Auto-audited eligibility candidate list
* `POST /api/college/bulk-approve` - Bulk approve candidates & release to recruiters
* `GET /api/college/placement-stats` - Executive KPIs (LPA, Average Package, Placed %)
* `GET /api/college/department-stats` - Stream comparative analytics (CS vs ME vs ECE)
* `GET /api/college/export-report` - Generate & download CSV / PDF reports

---

## 🚀 5. How to Setup & Start the Backend (Step-by-Step)

### Step 1: Install Dependencies
Terminal me root directory se execute karein:
```bash
npm install express mongoose dotenv cors jsonwebtoken bcryptjs
```

### Step 2: Configure Environment Variables (`.env`)
Project root me `.env` file ko setup karein:
```env
PORT=5000
NODE_ENV=development
MONGO_URI=mongodb+srv://YOUR_USER:YOUR_PASSWORD@cluster0.mongodb.net/campus2corporate?retryWrites=true&w=majority
JWT_SECRET=campus2corporate_super_secret_key_2026
```

### Step 3: Run the Backend Server
Backend server start karne ke liye terminal command chalaayein:
```bash
node server/server.js
```
Ya development mode me auto-restart ke liye:
```bash
npx nodemon server/server.js
```

Terminal me confirm hoga:
```
MongoDB Connected: cluster0.mongodb.net
Server running on port 5000
```
