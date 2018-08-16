#' Parameters for cwl
#' @importFrom S4Vectors SimpleList
setClass("cwlParam",
         slots = c(
             cwlVersion = "character",
             cwlClass = "character",
             baseCommand = "character",
             requirements = "character",
             hints = "character",
             arguments = "list",
             inputs = "InputParamList",
             outputs = "OutputParamList",
             stdout = "character",
             steps = "stepParamList"
         ),
         prototype = list(cwlVersion = character(),
                          cwlClass = character(),
                          baseCommand = character(),
                          requirements = character(),
                          hints = character(),
                          arguments = list(),
                          inputs = InputParamList(),
                          outputs = OutputParamList(),
                          stdout = character(),
                          steps = stepParamList()
         ))

cwlParam <- function(cwlVersion = "v1.0", cwlClass = "CommandLineTool",
                     baseCommand = character(), requirements = character(),
                     hints = character(), arguments = list(),
                     inputs = InputParamList(), outputs = OutputParamList(),
                     stdout = character(), steps = stepParamList()){
    new("cwlParam", cwlVersion = cwlVersion, cwlClass = cwlClass,
        baseCommand = baseCommand, requirements = requirements, hints = hints,
        arguments = arguments, inputs = inputs, outputs = outputs, stdout = stdout,
        steps = steps)
}

#' cwlVersion
cwlVersion <- function(cwl) cwl@cwlVersion

"cwlVersion<-" <- function(cwl, value){
    cwl@cwlVersion  <- value
    cwl
}
## setGeneric("cwlVersion<-")
## setReplaceMethod("cwlVersion", "cwlParam", function(cwl, value){
##     cwl@cwlVersion <- value
##     cwl
## })

#' cwlClass
cwlClass <- function(cwl) cwl@cwlClass
"cwlClass<-" <- function(cwl, value){
    cwl@cwlClass <- value
    cwl
}

## setGeneric("cwlClass<-")
## setReplaceMethod("cwlClass", "cwlParam", function(cwl, value){
##     cwl@cwlClass <- value
##     cwl
## })

#' baseCommand
baseCommand <- function(object) object@baseCommand
"baseCommand<-" <- function(cwl, value){
    cwl@baseCommand <- value
    cwl
}

## "baseCommand<-" <- function(cwl, value){cwl}
## setGeneric("baseCommand<-")
## setReplaceMethod("baseCommand", "cwlParam", function(object, value){
##     object@baseCommand <- value
##     object
## })

#' inputs
inputs <- function(cwl) cwl@inputs@inputs

#' Assign values to input params
## #' @param names list
## #' @param values list
assignInputs <- function(cwl, names, values){
    for(i in 1:length(names)){
        itype <- inputs(cwl)[[names[[i]]]]@type
        if(itype == "int"){
            v <- as.integer(values[[i]])
        }else if(itype %in% c("File", "Directory")){
            v <- list(class = "File", path = normalizePath(values[[i]]))
        }else{
            v <- values[[i]]
        }
        cwl@inputs@inputs[[names[[i]]]]@value <- v
    }
    cwl
}

#' assign value to each input list
.assignInput <- function(x, name, value){
    itype <- inputs(x)[[name]]@type
    if(is(itype, "InputArrayParam")){
        v <- value
    }else if(is(itype, "character")){
        if(itype == "int"){
            v <- as.integer(value)
        }else if(itype %in% c("File", "Directory")){
            if(!file.exists(value)) stop(value, " does not exist!")
            v <- list(class = itype, path = normalizePath(value))
        }else{
            v <- value
        }
    }
    x@inputs@inputs[[name]]@value <- v
    x
}

#' @export
setMethod("$", "cwlParam", function(x, name){
    inputs(x)[[name]]@value
})

#' @export
setReplaceMethod("$", "cwlParam", function(x, name, value){
    .assignInput(x, name, value)
})


#' Input parameters
setClassUnion("characterORInputArrayParam", c("character", "InputArrayParam"))

setClass("InputParam",
         slots = c(
             id = "character",
             label = "character",
             type = "characterORInputArrayParam",
             inputBinding = "list",
             default = "ANY",
             value = "ANY"
         ),
         prototype = list(
             id = character(),
             label = character(),
             type = character(),
             inputBinding = list(position = integer(),
                                 prefix = character(),
                                 separate = logical(),
                                 itemSeparator = character(),
                                 valueFrom = character()),
             default = character(),
             value = character())
         )

InputParam <- function(id, label= "", type = "string", position = 0L, prefix = "", separate = TRUE, itemSeparator = character(), valueFrom = character(), default = character(), value = character()){
    new("InputParam",
        id = id,
        label = label,
        type = type,
        inputBinding = list(position = as.integer(position),
                            prefix = prefix,
                            separate = separate,
                            itemSeparator = itemSeparator,
                            valueFrom = valueFrom),
        default = default,
        value = value)
}

#' InputArrayParam
#' @param items Defines the type of the array elements when type is a InputArrayParam class.
setClass("InputArrayParam",
         slots = c(
             label = "character",
             type = "character",
             items = "character",
             inputBinding = "list"
         ),
         prototype = list(
             label = character(),
             type = "string",
             items = character(),
             inputBinding = list(prefix = character(),
                                 separate = logical(),
                                 itemSeparator = character(),
                                 valueFrom = character()))
         )

InputArrayParam <- function(label= "", type = "string", items = character(), prefix = "", separate = TRUE, itemSeparator = character(), valueFrom = character()){
    new("InputArrayParam",
        label = label,
        type = type,
        items = items,
        inputBinding = list(prefix = prefix,
                            separate = separate,
                            itemSeparator = itemSeparator,
                            valueFrom = valueFrom))
}

setClass("InputParamList", slots = c(inputs = "SimpleList"))

InputParamList <- function(...){
    iList <- SimpleList(...)
    names(iList) <- lapply(iList, function(x)x@id)
    new("InputParamList", inputs = iList)
}

#' Output array parameters
setClass("OutputArrayParam",
         slots = c(
             label = "character",
             type = "character",
             items = "character",
             outputBinding = "list"
         ),
         prototype = list(
             label = character(),
             type = "string",
             items = character(),
             outputBinding = list(glob = character(),
                                 loadContents = logical(),
                                 outputEval = character()))
         )

OutputArrayParam <- function(label= character(), type = "string", items = character(),
                             glob = character(), loadContents = logical(),
                             outputEval = character()){
    new("OutputArrayParam",
        label = label,
        type = type,
        items = items,
        outputBinding = list(glob = glob,
                            localContents = loadContents,
                            outputEval = outputEval))
}

setClassUnion("characterOROutputArrayParam", c("character", "OutputArrayParam"))

#' Output parameters
#' @param items from step parameters
setClass("OutputParam",
         slots = c(
             id = "character",
             label = "character",
             type = "characterOROutputArrayParam",
             streamable = "logical",
             outputBinding = "list",
             items = "character",
             outputSource = "character"
         ),
         prototype = list(id = character(),
                          label = character(),
                          type = character(),
                          streamable = logical(),
                          items = character(),
                          outputBinding = list(glob = character(),
                                               loadContents = logical(),
                                               outputEval = character()),
                          outputSource = character())
         )

OutputParam <- function(id = "output", label = character(), type = "stdout",
                        items = character(), streamable = logical(),
                        glob = character(), loadContents = logical(), outputEval = character(),
                        outputSource = character()){
    ##if(items %in% c("File", "Directory") && type != "array") stop("type must be array!")
    new("OutputParam",
        id = id,
        label = label,
        type = type,
        streamable = streamable,
        items = items,
        outputBinding = list(glob = glob,
                             loadContents = loadContents,
                             outputEval = outputEval),
        outputSource = outputSource)
}

setClass("OutputParamList", slots = c(outputs = "SimpleList"))
OutputParamList <- function(out = OutputParam(), ...){
    oList <- SimpleList(out, ...)
    names(oList) <- lapply(oList, function(x)x@id)
    new("OutputParamList", outputs = oList)
}

#' outputs
outputs <- function(cwl) cwl@outputs@outputs

#' Assign values to input params
assignOutputGlob <- function(cwl, name="output", value){
    itype <- cwl@outputs$output@type
    stopifnot(itype != "File")
    cwl@outputs$output@outputBinding$glob <- value
    cwl
}

#' show method
setMethod(show, "InputParamList", function(object) {
    cat("inputs:\n")
    lapply(seq(object@inputs), function(i){
        if(object@inputs[[i]]@label != ""){
            iname <- paste0(names(object@inputs)[i], " (", object@inputs[[i]]@label, ") ")
        }else{
            iname <- names(object@inputs)[i]
        }
        if(is(object@inputs[[i]]@type, "character")){
            if(object@inputs[[i]]@type %in% c("File", "Directory")){
                if(length(object@inputs[[i]]@value) > 0){
                    v <- object@inputs[[i]]@value$path
                }else{
                    v <- object@inputs[[i]]@value
                }
            }else{
                v <- object@inputs[[i]]@value
            }

            cat("  ", iname, ": ",
                object@inputs[[i]]@inputBinding$prefix, " ",
                paste(unlist(v), collapse = " "), "\n", sep = "")
        }else if(is(object@inputs[[i]]@type, "InputArrayParam")){
            if(object@inputs[[i]]@type@items %in% c("File", "Directory")){
                if(length(object@inputs[[i]]@value) > 0){
                    v <- object@inputs[[i]]@value$path
                }else{
                    v <- object@inputs[[i]]@value
                }
            }else{
                v <- object@inputs[[i]]@value
            }
            cat("  ", iname, ":\n", sep = "")
            cat("    type: ", object@inputs[[i]]@type@type, "\n", sep = "")
            cat("    prefix: ",
                object@inputs[[i]]@type@inputBinding$prefix, " ",
                paste(unlist(v), collapse=" "), "\n", sep = "")
        }
    })
})

setMethod(show, "OutputParamList", function(object) {
    cat("outputs:\n")
    lapply(seq(object@outputs), function(j){
        cat("  ", object@outputs[[j]]@id, ":\n", sep = "")
        
        if(is(object@outputs[[j]]@type, "OutputArrayParam")){
            cat("    type: array\n")
        }else{
            cat("    type: ", object@outputs[[j]]@type, "\n", sep = "")
            if(object@outputs[[j]]@type != "stdout"){
                if(object@outputs[[j]]@outputBinding$glob != ""){
                    cat("      glob: ", object@outputs[[j]]@outputBinding$glob, "\n", sep = "")
                }
                if(object@outputs[[j]]@outputSource != ""){
                    cat("    outputSource: ", object@outputs[[j]]@outputSource, "\n", sep = "")
                }
            }
        }
    })
})

setMethod(show, "cwlParam", function(object){
    cat("class: cwlParam\n")
    cat("cwlClass:", cwlClass(object), "\n")
    cat("cwlVersion:", cwlVersion(object), "\n")
    cat("baseCommand:", baseCommand(object), "\n")
    if(length(object@requirements) > 0){
        cat("requirements:", object@requirements, "\n")
    }
    if(length(object@hints) > 0){
        cat("hints:", object@hints, "\n")
    }
    if(length(object@arguments) > 0){
        cat("arguments:", unlist(object@arguments), "\n")
    }
    show(object@inputs)
    show(object@outputs)
    if(length(object@stdout) > 0) cat("stdout:", object@stdout, "\n")
    if(cwlClass(object) == "Workflow") {
        show(object@steps)
    }
})
