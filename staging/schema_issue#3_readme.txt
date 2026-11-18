description of issue#3:

Resource:

1.	Enforcing Disjointness (Pure Constraints - No Triggers Needed)
To guarantee that a Resource can never belong to more than one subclass (e.g., cannot be both a Quiz and an Assignment), add a Resource_Type discriminator column to Resource and include it in the Foreign Keys.

2. Enforcing Total Participation & Solving the Insert Order Problem
"Chicken and egg problem" -> Solve by either adding a procedure or instead of trigger into a View.

3. Subclass ON DELETE CASCADE: Ensure no Resource exist without a type.

Quiz:

- Attempt_Limit must be >= 1
- Quiz_Time_limit must be 0 < x <= 86400 (enforce theo attempt của Hoàng)
- Grade_To_Pass DECIMAL(4, 2): 0.00 - 10.00

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