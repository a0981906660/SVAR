
## Replication Instruction

This R project is created with RStudio, so it works the best to run all the script under RStudio. All path is written in relative path under the project root folder.

You may also run all the scripts by the following command:
```shell
cd PROJECT_FOLDER
Rscript code/master_script.R
```

Please refer to `code/mater_script.R` for step-by-step details. 


## Prepare the environment
```R
renv::install()
```
Consider installing these packages (for example, using `renv::install()`).
Then, use `renv::snapshot()` to record these packages in the lockfile.
Use `renv::dependencies()` to see where these packages appear to be used.



# Tasks
1. Replicate Fig 4--12. Fig 7 can be skipped
2. Replicate Tab 3--7
