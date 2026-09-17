// Core application constants, sample documents, categories, and legal disclaimers.

class AppConstants {
  static const String appName = 'LegalLens AI';
  static const String appTagline = 'Understand Before You Sign';
  static const String appVersion = '1.0.0';

  // Legal Disclaimers (MANDATORY across views)
  static const String legalDisclaimerShort =
      'LegalLens AI provides legal information and document assistance, not legal advice. Always consult a licensed attorney for specific legal situations.';

  static const String legalDisclaimerFull =
      'LegalLens AI provides general legal information and document assistance, not legal advice. '
      'AI-generated results may be incomplete or inaccurate. For decisions involving your legal rights, '
      'obligations, or specific circumstances, consult a qualified legal professional.';

  static const String lowConfidenceWarning =
      'AI confidence is low. Please review the original clause carefully or consult a legal professional.';

  static const String noHallucinationRefusal =
      'I couldn\'t find this information in the provided document.';

  static const String notDetectedDate = 'Not detected.';

  // Document Categories
  static const List<String> documentCategories = [
    'Employment Agreement',
    'Rental / Lease Agreement',
    'Freelance Agreement',
    'Service Agreement',
    'NDA',
    'Offer Letter',
    'Terms & Conditions',
    'Privacy Policy',
    'Purchase Agreement',
    'General Contract',
    'Other',
  ];

  // Clause Categories (15 categories)
  static const List<String> clauseCategories = [
    'Payment',
    'Termination',
    'Notice',
    'Confidentiality',
    'Intellectual Property',
    'Liability',
    'Indemnity',
    'Non-Compete',
    'Non-Solicitation',
    'Dispute Resolution',
    'Governing Law',
    'Renewal',
    'Penalties',
    'Refunds',
    'Data Privacy',
  ];

  // Risk Categories (6 categories)
  static const List<String> riskCategories = [
    'Financial',
    'Employment',
    'Privacy',
    'Liability',
    'Intellectual Property',
    'Restrictions',
  ];

  // Sample Documents for 1-Click Evaluation
  static const String sampleEmploymentContract = '''
EMPLOYMENT AGREEMENT

This Employment Agreement ("Agreement") is made and entered into as of October 1, 2025 ("Effective Date"), by and between Nexus Cloud Technologies Inc., a Delaware corporation ("Employer"), and Alex Rivera ("Employee").

1. POSITION AND DUTIES
1.1 Position: Employer employs Employee as Principal Systems Engineer.
1.2 Probationary Period: Employee shall be subject to a 90-day probation period commencing on the Effective Date.

2. COMPENSATION AND BENEFITS
2.1 Base Salary: Employer shall pay Employee a base salary of \$185,000 per annum, payable in semi-monthly installments.
2.2 Discretionary Bonus: Employee is eligible for an annual discretionary performance bonus of up to 20% of base salary, subject to board approval.
2.3 Payment Deadline: Monthly expense reimbursements shall be submitted within 30 days and reimbursed on the subsequent pay cycle.

3. TERM AND TERMINATION
3.1 At-Will Employment: Employment is at-will. Either party may terminate this Agreement at any time, with or without cause, upon providing ninety (90) days written notice.
3.2 Termination for Cause: Employer may terminate employment immediately without notice in cases of gross negligence, fraud, or willful misconduct.
3.3 Severance: Upon termination without cause, Employee shall receive two (2) months base salary subject to signing a general release of claims.

4. CONFIDENTIALITY AND PROPRIETARY INFORMATION
4.1 Confidentiality: Employee agrees to hold in strict confidence all trade secrets, source code, customer lists, and financial information during and for five (5) years after employment.
4.2 Non-Disclosure: Employee shall not disclose confidential proprietary data to any third party without prior written authorization from Employer.

5. INTELLECTUAL PROPERTY AND WORK FOR HIRE
5.1 Work Product Ownership: Employee agrees that all inventions, designs, algorithms, code, patents, and work products conceived, developed, or reduced to practice during employment—whether created on company premises or at home, during or outside standard working hours, using company equipment or personal equipment if related to company business—are works made for hire and shall belong exclusively to Employer.
5.2 Prior Inventions: Inventions created prior to employment must be listed on Exhibit A. Any unlisted invention shall be presumed company property.

6. RESTRICTIVE COVENANTS
6.1 Non-Compete: During the term of employment and for a period of twelve (12) months following termination of employment for any reason, Employee shall not directly or indirectly engage in, perform services for, invest in, or consult with any enterprise in North America or Europe that competes directly with Employer's cloud computing optimization products.
6.2 Non-Solicitation of Employees and Clients: For twenty-four (24) months post-termination, Employee shall not solicit or induce any employee, contractor, or customer of Employer to terminate their relationship.

7. INDEMNIFICATION AND LIABILITY
7.1 Employee Indemnity: Employee agrees to indemnify, defend, and hold harmless Employer, its directors, and officers from and against any third-party claims, liabilities, or losses arising out of Employee's gross negligence, willful misconduct, or unauthorized public statements.
7.2 Limitation of Liability: Employer's total liability under this Agreement shall not exceed the compensation paid to Employee during the preceding three (3) months.

8. DISPUTE RESOLUTION AND GOVERNING LAW
8.1 Mandatory Arbitration: Any dispute, controversy, or claim arising out of or relating to this Agreement shall be settled by binding individual arbitration administered by JAMS in Wilmington, Delaware. Class actions and jury trials are expressly waived.
8.2 Governing Law: This Agreement shall be governed by and construed in accordance with the laws of the State of Delaware, without regard to conflict of law principles.

9. MISCELLANEOUS
9.1 Entire Agreement: This Agreement constitutes the complete agreement between the parties and supersedes all prior oral or written negotiations.
9.2 Amendments: No modification of this Agreement shall be effective unless in writing signed by both parties.
''';

  static const String sampleLeaseAgreement = '''
RESIDENTIAL LEASE AGREEMENT

This Residential Lease Agreement ("Lease") is entered into on June 1, 2025, between Metro Urban Properties LLC ("Landlord") and Jordan Taylor ("Tenant").

1. PREMISES AND TERM
1.1 Property: Landlord leases to Tenant Unit 402 located at 742 Evergreen Terrace, Metropolis.
1.2 Lease Term: The initial term shall be twelve (12) months, beginning July 1, 2025 ("Commencement Date") and expiring June 30, 2026 ("Expiration Date").
1.3 Automatic Renewal: This Lease shall automatically renew on a month-to-month basis unless either party provides sixty (60) days advance written notice prior to the expiration date.

2. RENT AND PAYMENT DEADLINES
2.1 Monthly Rent: Tenant shall pay Landlord \$2,450 per month, due promptly on the first (1st) day of each calendar month.
2.2 Late Fee and Penalties: If rent is not received by the fifth (5th) day of the month, Tenant shall pay a late fee of \$125, plus \$15 per day until paid in full.
2.3 Security Deposit: Tenant shall deposit with Landlord \$3,675 (1.5 months rent) as security for faithful performance. The deposit shall be returned within thirty (30) days after vacating, less documented damages.

3. REPAIRS AND MAINTENANCE
3.1 Tenant Responsibilities: Tenant shall keep the premises clean and sanitary, promptly dispose of trash, and bear costs for minor plumbing repairs under \$100.
3.2 Landlord Responsibilities: Landlord shall maintain structural components, roof, electrical systems, and central heating in good working order.
3.3 Shared Responsibility: Landlord and Tenant shall jointly conduct move-in and move-out inspections.

4. RESTRICTIONS AND SUBLETTING
4.1 Subletting and Assignment: Tenant shall not sublet the premises or assign this Lease without prior written consent from Landlord. Unauthorized short-term rentals (e.g., Airbnb) result in immediate termination and a \$1,000 penalty.
4.2 Quiet Enjoyment and Pets: No unauthorized pets allowed without \$500 pet deposit. Quiet hours enforced between 10:00 PM and 7:00 AM.

5. ENTRY AND INSPECTION
5.1 Landlord Access: Landlord reserves the right to enter premises with twenty-four (24) hours advance notice for inspections or repairs, and immediately in case of emergency.

6. INDEMNIFICATION AND LIABILITY
6.1 Tenant Indemnity: Tenant agrees to indemnify and hold Landlord harmless from any claims, property damage, or bodily injuries occurring inside the leased premises caused by Tenant or guests.
6.2 Renter Insurance: Tenant is required to maintain active renter's insurance with a minimum \$300,000 liability coverage throughout the lease term.

7. GOVERNING LAW AND DISPUTES
7.1 Jurisdiction: Governed by the laws of the State of New York. Disputes shall be resolved in New York Housing Court.
''';

  static const String sampleMutualNDA = '''
MUTUAL NON-DISCLOSURE AGREEMENT (NDA)

This Mutual Non-Disclosure Agreement ("Agreement") is entered into on August 15, 2025 ("Effective Date"), by and between Apex Ventures Inc. and Horizon Data Solutions LLC (each a "Party" and collectively the "Parties").

1. PURPOSE
The Parties wish to explore potential collaborative software integration and strategic investment opportunities ("Purpose").

2. DEFINITION OF CONFIDENTIAL INFORMATION
2.1 Scope: "Confidential Information" means all non-public technical, operational, customer, financial, product roadmap, and source code disclosures marked as confidential or that reasonably should be understood as confidential.
2.2 Exclusions: Confidential Information does not include information that: (a) is or becomes publicly known through no breach; (b) was already known prior to disclosure; (c) is independently developed without reference to the disclosure; or (d) is required to be disclosed by court order.

3. OBLIGATIONS OF RECEIVING PARTY
3.1 Duty of Care: Each Party shall protect the other Party's Confidential Information with the same degree of care it uses for its own confidential information, but not less than reasonable care.
3.2 Restricted Use: Receiving Party shall use Confidential Information solely for the Purpose and disclose it only to employees and advisors with a need to know who are bound by non-disclosure terms at least as restrictive.

4. TERM AND SURVIVAL
4.1 Term: This Agreement shall remain in effect for three (3) years from the Effective Date.
4.2 Survival: Confidentiality obligations with respect to trade secrets and source code shall survive indefinitely; all other proprietary data obligations shall survive for five (5) years following termination.

5. RETURN OF MATERIALS
Within ten (10) business days following written request, Receiving Party shall return or certify destruction of all documents, prototypes, and electronic copies containing Confidential Information.

6. REMEDIES AND INJUNCTIVE RELIEF
The Parties acknowledge that unauthorized disclosure causes irreparable harm for which monetary damages are inadequate, and the Disclosing Party shall be entitled to seek immediate injunctive relief without posting bond.

7. GOVERNING LAW
This Agreement shall be governed by the laws of California, without giving effect to conflict of law principles.
''';

  static const String sampleComparisonOfferA = '''
EMPLOYMENT OFFER LETTER - OPTION A (STANDARD ENTERPRISE)
Position: Senior Software Architect
Base Compensation: \$165,000 per annum.
Sign-on Bonus: \$15,000 subject to 12 months clawback if voluntary departure.
Termination Notice: Either party may terminate with 30 days written notice.
Probation Period: 90 days probation.
Non-Compete: 6 months post-employment non-compete restricted to direct competitors in California.
IP Ownership: Work produced during working hours using company assets belongs to Employer.
Dispute Resolution: Binding arbitration under AAA rules in San Francisco, CA.
Severance: 1 month base salary upon termination without cause.
''';

  static const String sampleComparisonOfferB = '''
EMPLOYMENT OFFER LETTER - OPTION B (FAST-GROWTH STARTUP)
Position: Principal Software Architect
Base Compensation: \$180,000 per annum with 0.5% equity grant vesting over 4 years.
Sign-on Bonus: \$25,000 subject to 24 months clawback if voluntary departure.
Termination Notice: Either party may terminate with 90 days written notice.
Probation Period: 180 days probation period.
Non-Compete: 18 months nationwide non-compete covering all software and technology sectors.
IP Ownership: Broad assignment of all intellectual property, algorithms, and ideas created at any time during employment, whether at work or on personal time.
Dispute Resolution: Mandatory individual arbitration with JAMS in Delaware; employee pays arbitration filing fees.
Severance: No severance entitlement upon termination without cause.
''';
}
