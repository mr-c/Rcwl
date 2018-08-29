
## test echo
a <- InputParam(id = "a", prefix = "-i", value = 1)
b <- InputParam(id = "b", value = "b")
c1 <- cwlParam(inputs = InputParamList(a, b))

a <- InputParam(id = "a", type = "File", prefix = "-i=", label = "test", separate = FALSE)
b <- InputParam(id = "b", type = "int", prefix = "-b")
c2 <- cwlParam(baseCommand = "echo", inputs = InputParamList(a, b))
c2$a <- "../cwl/test"
c2$b <- 1

writeCWL(c2, "../cwl/test")
c2res <- runCWL(c2)
test_that("simple echo", {
    expect_equal(tail(c2res$logs, 1), "Final process status is success")})

## Input array
a <- InputParam(id = "a", type = "int[]", prefix = "-i", label = "test")
b <- InputParam(id = "b",
                type = InputArrayParam(type="array", items = "string", prefix="-B=", separate = FALSE))
d <- InputParam(id = "d", type = "string[]", prefix = "-C=", itemSeparator = ",", separate = FALSE)
c3 <- cwlParam(baseCommand = "echo", inputs = InputParamList(a, b, d), stdout = "output.txt")
c3$a <- 1:3
c3$b <- c("A", "B", "C")
c3$d <- letters[1:3]
c3res <- runCWL(c3)
test_that("Input array", {
    expect_equal(tail(c3res$logs, 1), "Final process status is success")})

## ## Output array
## a <- InputParam(id = "a", type = InputArrayParam(type = "array", items = "string"))
## b <- OutputParam(id = "b", type = OutputArrayParam(type = "array", items = "File"), glob = "*.txt")
## c4 <- cwlParam(baseCommand = "touch", inputs = InputParamList(a), outputs = OutputParamList(b))
## c4$a <- c("a.txt", "b.gz", "c.txt")
## c4res <- runCWL(c4)

## ## SGE
## library(BiocParallel)

## testRun <- function(n, cwl) {
##     ##paste(n, cwl$b)
##     cwl$b  <- n
##     ##cwl <- assignInputs(cwl, "b", n)
##     runCWL(cwl)
## }

## template <- system.file(
##     package = "BiocParallel",
##     "unitTests", "test_script", "test-sge-template.tmpl"
## )

## param1 <- MulticoreParam(4)
## results <- bplapply(1:10, testRun, BPPARAM = param1, cwl=c2)

## regArgs <- batchtoolsRegistryargs(packages = "RPipe")
## param <- BatchtoolsParam(workers=4, cluster="sge", template=template, registryargs = regArgs)
## results <- bplapply(1:4, testRun, BPPARAM = param, cwl=c2)

## ## docker
## a <- InputParam(id = "src", type = "File")
## c5 <- cwlParam(baseCommand = "node", inputs = InputParamList(a), stdout = "output.txt",
##                hints = list(DockerRequirement = list(dockerPull = "node:slim")))

## ### workflow
## ## tar uncompress a file
## i1 <- InputParam(id = "tarfile", type = "File")
## o1 <- OutputParam(id = "tarout", type = "File", glob = "*.java")
## p1 <- cwlParam(baseCommand = c("tar", "xf"), inputs = InputParamList(i1), outputs = OutputParamList(o1))
## p1$tarfile <- "../cwl/hello.tar"
## r1 <- runCWL(p1)

## ## javac compile
## i2 <- InputParam(id = "compile", type = "File")
## ##i3 <- InputParam(id = "wdir", type = "Directory", position = 1, prefix = "-d")
## o2 <- OutputParam(id = "classfile", type = "File", glob = "*.class")
## p2 <- cwlParam(baseCommand = "javac", inputs = InputParamList(i2), outputs = OutputParamList(o2), arguments = list("-d", "$(runtime.outdir)"))
## p2$compile <- "../cwl/Hello.java"
## r2 <- runCWL(p2)

## ## pipeline p1 + p2
## ## detailed
## i1 <- InputParam(id = "inp", type = "File")
## o1 <- OutputParam(id = "classout", type = "File", outputSource = "Compile/classfile")

## s1 <- stepParam(id = "Untar", run = p1,
##                 In = stepInParamList(stepInParam(id = names(inputs(p1)), source = "inp")),
##                 Out = list("tarout"))
## s2 <- stepParam(id = "Compile", run = p2,
##                 In = stepInParamList(stepInParam(id = names(inputs(p2)), source = "Untar/example_out")),
##                 Out = list("classfile"))
## ss <- stepParamList(s1, s2)
## cwl1 <- cwlStepParam(cwlClass = "Workflow",
##                      inputs = InputParamList(i1),
##                      outputs = OutputParamList(o1),
##                      steps = ss
##                      )
## ## Step+ method
## cwl2 <- cwlStepParam(cwlClass = "Workflow",
##                      inputs = InputParamList(i1),
##                      outputs = OutputParamList(o1))
## s1 <- Step(id = "Untar", run = p1, In = list(tarfile = "inp"))
## s2 <- Step(id = "Compile", run = p2, In = list(compile = "Untar/tarout"))
## cwl2 <- cwl2 + s1 + s2

## cwl2$inp <- "../cwl/hello.tar"
## r3 <- runCWL(cwl2)

## test_that("Two steps workflow", {
##     expect_equal(tail(r3$logs, 1), "Final process status is success")})