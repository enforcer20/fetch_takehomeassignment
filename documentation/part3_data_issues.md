
# Data Quality Issues Identified (Reassessed from JSON Sources)

## 1. **Missing Data**

### Users Table:
- **Last Login Date:** 62 user records are missing the last login date.
- **Sign-Up Source:** 48 missing entries, impacting user acquisition analysis.
- **State:** 56 user entries missing state information, limiting geographic segmentation.

### Brands Table:
- **Brand Code:** 234 missing entries, which can affect brand identification.
- **Category:** 155 missing entries, impacting product classification.
- **Category Code:** 650 missing entries, affecting category-based grouping.
- **Top Brand Indicator:** 612 missing entries for the `topBrand` field.

### Receipts Table:
- **Bonus Points Fields:** 575 missing entries in `bonusPointsEarned` and `bonusPointsEarnedReason`.
- **Points Earned:** 510 missing entries.
- **Purchased Item Count:** 484 missing entries.
- **Rewards Receipt Item List:** 440 missing entries.
- **Total Spent:** 435 missing entries.
- **Finished Date:** 551 missing entries in `finishedDate`.
- **Points Awarded Date:** 582 missing entries.
- **Purchase Date:** 448 missing entries.

---

## 2. **Duplicate Records**
- **Users Table:** 283 duplicate user entries, potentially inflating user counts.
- **Brands Table:** No duplicates found.
- **Receipts Table:** No duplicates detected after resolving list-type field issues.

---

## 3. **Inconsistent Data Types**

### Date Fields:
- Fields such as `createdDate` and `lastLogin` are stored as UNIX timestamps.

### Top Brand Indicator:
- The `topBrand` field is now correctly identified as a **boolean** after reassessment.

---

## 4. **Referential Integrity Issues**
- **User ID Matching:** Not all `userId` values in receipts match records in the users table (**Integrity Issue Found**).
- **Brand ID Matching:** All `brand_id` values are present (**No issues found**).

---

## 5. **Logical Consistency Concerns**

### User Data:
- No inconsistencies found between `createdDate` and `lastLogin`.

### Receipt Data:
- **Invalid Date Sequences:** 13 receipts have `purchaseDate` later than `dateScanned`, which is logically inconsistent.

---

## ✅ **Next Steps for Normalizing Data**

1. **Address Missing Data:**
   - Impute missing values where possible or exclude affected records.

2. **Deduplicate Data:**
   - Remove or merge duplicate user entries after further validation.

3. **Convert Date Fields:**
   - Transform UNIX timestamps into readable date formats.

4. **Ensure Referential Integrity:**
   - Investigate and correct user ID mismatches in receipts.

5. **Validate Logical Consistency:**
   - Review and correct 13 inconsistent receipt date entries.

---

By addressing these issues, the data will be more reliable, supporting accurate and efficient analytics workflows.
