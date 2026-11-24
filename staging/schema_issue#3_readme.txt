description of issue#3:

description of issue#3:

Resource:

1. Enforcing Disjointness (Handled via Insert Procedure for Now)
Using Option 8A mapping (no Resource_Type discriminator column in Resource). Disjointness across Quiz, Assignment, and File_material is not enforced via constraints or triggers yet; the insert procedure will ensure each Resource ID is only inserted into one subclass.

2. Enforcing Total Participation & Solving the Insert Order Problem
"Chicken and egg problem" -> Solve by adding a stored procedure (or INSTEAD OF trigger on a View) to insert into Resource, its subclass, Creates, and Includes within a single transaction.

3. Subclass ON DELETE CASCADE: Deleting a Resource automatically deletes its corresponding subclass record (Quiz, Assignment, or File_material) so no orphaned subclass rows remain.

Quiz:

- Attempt_Limit must be >= 1 (NULL allowed if unlimited)
- Time_limit must be 0 < x <= 86400, DEFAULT 86400 NOT NULL (enforce theo attempt của Hoàng)
- Grade_To_Pass DECIMAL(4, 2) DEFAULT 0.00 NOT NULL: 0.00 - 10.00

Assignment:

- number_of_review_require >= 0 (allow 0 if the assignment does not need peer review)

File_material:

- File_url max 300 theo Hoàng

Creates:

- Upload_person is BIT (the main person is 1, others 0)?
- Upload_person is NVARCHAR (the name of the main person)?
- Teacher(ID) ON DELETE NO ACTION: A Resource is co-own by many Teachers. Note: Prevent deleting a Teacher if doing so would leave a Resource with zero creators (need trigger for this).
- Resource(ID) ON DELETE CASCADE: If a Resource is deleted, its authorship links are cleaned up automatically.

Includes:

- Resource(ID) ON DELETE CASCADE: Same as above
- Session ON DELETE NO ACTION: If a Session is deleted, cascading that delete into Include might remove the only session a Resource belongs to. (need a better way to handle this).