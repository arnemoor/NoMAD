# Project Structure
NoMAD uses a simple two branch structure. Combined with a feature branch workflow changes are encapsulated and easy to merge. At the same time all code changes are documented by the workflow.

The basic branches are:
* Master
    * This is the branch that only ever holds finished release code
* Experimental
    * The development branch. (This branch should **always** build clean!)

# Feature Branch Workflow
Using feature branches in git is very easy.

1. Open a ticket that describes the changes to be made to the code.
![Screen_Shot_2016-10-31_at_2.27.13_PM](/uploads/c420a5725e32df9e11384013478fecf5/Screen_Shot_2016-10-31_at_2.27.13_PM.png)
2. Pull to update your local copy of Experimental, then make a new branch with the naming syntax of Username-Issue-Description.
![Screen_Shot_2016-10-31_at_2.28.15_PM](/uploads/5a3f75b9625537563fe601fa0ce09148/Screen_Shot_2016-10-31_at_2.28.15_PM.png)
3. Edit code in the feature branch, committing and pushing like normal.
![Screen_Shot_2016-10-31_at_2.30.54_PM](/uploads/380d9382f7354f4ae20d2c7dd96e00ae/Screen_Shot_2016-10-31_at_2.30.54_PM.png)
4. When you are satisfied with your changes, submit a merge request that references the issue ticket. (Gitlab makes this easy to do with issue number auto-complete.)

*Opening a merge request*
![Screen_Shot_2016-10-31_at_2.32.45_PM](/uploads/0d088010412c7d2bb812c4fb330df4e2/Screen_Shot_2016-10-31_at_2.32.45_PM.png)
*Filling in merge request info*
![Screen_Shot_2016-10-31_at_2.54.44_PM](/uploads/db18526769e858d13a6632173081c089/Screen_Shot_2016-10-31_at_2.54.44_PM.png)
    5. Once the request is accepted, update the ticket with the git commit that the changes landed in if Gitlab didn’t associate them automatically.
![Screen_Shot_2016-10-31_at_3-1.33.13_PM](/uploads/1473e0b11160b31b300f3aae5887eb3c/Screen_Shot_2016-10-31_at_3-1.33.13_PM.png)
![Screen_Shot_2016-10-31_at_3.55.02_PM](/uploads/e0d342b247e0da44e7d3cf68093b8a5e/Screen_Shot_2016-10-31_at_3.55.02_PM.png)
    6. Delete the feature branch if it wasn’t automated in the merge accept.