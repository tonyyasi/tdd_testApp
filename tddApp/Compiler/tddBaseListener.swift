// Generated from tdd.g4 by ANTLR 4.7.2

import Antlr4

enum SolvingDimen {
    case array
    case matrix
    case none
}

struct Test {
    let name: String
    var params: [String]
    var returnVal: String
}

// Little helper function to facilitate getting substrings
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}

let semanticCube = SemanticCube()

var symbols = SymbolTable()
var scope: String = "error"

var sfunction_param_index = [Int]()

var solvingDimen: SolvingDimen = .none

//Stacks
var sOperators = [String]()
var sOperands = [Int]()
var sTypes = [Type]()
var arrayQuads = [Quadruple]()
var sJumps = [Int]() //Contains index of unfilled quadruple
var sGoto = [Int]()
var sFunctions = [Function]()
var tests = [Test]()
// (Base address of array or matrix , (First dimension, second dimension))
var pendingArrayAddresses = [Variable]()

public var error : Bool = false
public var message = ""

var docCurrFunName = ""

//Memories
let globalMemory = Memory(dirBase: 0)
let constantMemory = Memory(dirBase: 10000)
let temporalMemory = Memory(dirBase: 20000)
let localMemory = Memory(dirBase: 30000)

var constantVals = ExecMemory(dirBase: 10000)

func findType(value: String) -> Type {
    var sType : String = "int"
    if value.starts(with: "\"") {
        sType = "string"
    }
    else if value.starts(with: "\'") {
        sType = "char"
    }
    else if value == "true" || value == "false" {
        sType = "bool"
    }
    else if value.contains(".") {
        sType = "float"
    }
    return Type(type: sType)
}

func createTemp(type: Type) -> Int {
    switch type {
    case .int:
        return temporalMemory.addInt()
    case .float:
        return temporalMemory.addFloat()
    case .string:
        return temporalMemory.addString()
    case .bool:
        return temporalMemory.addBool()
    case .char:
        return temporalMemory.addChar()
    case .error, .void:
        return -1
    }
}

func createVariable(memory: Memory, id: String, type: Type, input: Bool = false, size: Int = 1, dimensionated: Bool = false, x: Int = 1, y: Int = 1) -> Variable {
    let address: Int!
    switch type {
    case .int:
        address = memory.addInt(size: size)
    case .float:
        address = memory.addFloat(size: size)
    case .string:
        address = memory.addString(size: size)
    case .bool:
        address = memory.addBool(size: size)
    case .char:
        address = memory.addChar(size: size)
    case .error, .void:
        address = -1
    }
    // TODO: Handle error in case the address is -1
    return Variable(name: id, type: type, address: address, input: input, dimensionated: dimensionated, size: size, x: x, y: y)
}

func solveQuad() {
    arrayQuads[sJumps.first!].fillMissingResult(result: arrayQuads.count)
    sJumps.removeFirst()
}

func createQuad() -> Quadruple {
    let currentOperator = sOperators.first!
     sOperators.removeFirst()
     let rightOperand = sOperands.first!
     let rightType = sTypes.first!
     sTypes.removeFirst()
     sOperands.removeFirst()
    let leftOperand = sOperands.first!
    let leftType = sTypes.first!
    sTypes.removeFirst()
    sOperands.removeFirst()
     if !semanticCube.checkCube(currOperator: currentOperator, leftType: leftType, rightType: rightType) {
         // TODO: There was a semantic error with the typing
     }
    
    let newType = semanticCube.getResultType(currOperator: currentOperator, leftType: leftType, rightType: rightType)
     let temporalMemoryAssignedSpace = createTemp(type:newType)
     let newQuad = Quadruple(quadOperator: currentOperator, leftOperand: leftOperand, rightOperand: rightOperand, result: temporalMemoryAssignedSpace)
    sOperands.insert(temporalMemoryAssignedSpace, at: 0)
    sTypes.insert(newType, at: 0)
    
    return newQuad
}

func addParamQuad() -> Quadruple {
    let function = sFunctions.first!
    if sfunction_param_index.first! >= function.input_total || !function.variables[function.input_total - sfunction_param_index.first! - 1].input {
        print("ERROR argument quantity mismatch")
        message += "Arguments quantity mismatch error\n"
        error = true
    }
    let currentVar = function.variables[function.input_total - sfunction_param_index.first! - 1]
    if sTypes.first! != currentVar.type {
        print("ERROR types mismatch")
        message += "Types mismatch error\n"
        error = true
    }
    // Potential way to not allow arrays as parameters
//    if function.variables[function.input_total - function_param_index - 1].dimensionated {
//        print("Error, no dimensionated variables as parameters")
//    }
    
    let newQuad = Quadruple(quadOperator: "PARAM", leftOperand: sOperands.first!, rightOperand: currentVar.size, result: currentVar.address)
    sTypes.removeFirst()
    sOperands.removeFirst()
    
    return newQuad
}

func genQuadTest(test: Test) {
    let function = symbols.functionsDictionary[test.name]!
    let eraQuad = Quadruple(quadOperator: "ERA", leftOperand: function.start_quadruple, rightOperand: 0, result: 0)
    arrayQuads.append(eraQuad)
    var paramQuad: Quadruple
    var index : Int = 0
    for param in test.params {
        let variable = createVariable(memory: constantMemory, id: param, type: findType(value: param))
        constantVals.saveToVals(address: variable.address, value: variable.name)
        paramQuad = Quadruple(quadOperator: "PARAM", leftOperand: variable.address, rightOperand: variable.size, result: function.variables[index].address)
        arrayQuads.append(paramQuad)
        index = index + 1
    }
    let goSub = Quadruple(quadOperator: "GOSUB", leftOperand: function.start_quadruple, rightOperand: 0, result: 0)
    arrayQuads.append(goSub)
    let testVal = createVariable(memory: constantMemory, id: test.returnVal, type: findType(value: test.returnVal))
    constantVals.saveToVals(address: testVal.address, value: testVal.name)
    let tmpRes = createTemp(type: .bool)
    let testEqual = Quadruple(quadOperator: "!=", leftOperand: function.return_address, rightOperand: testVal.address, result: tmpRes)
    arrayQuads.append(testEqual)
    
    let gotoF = Quadruple(quadOperator: "GOTOF", leftOperand: tmpRes, rightOperand: -1, result: arrayQuads.count + 3)
    arrayQuads.append(gotoF)
    
    let testMessage = createVariable(memory: constantMemory, id: "EERROR en unit tests de " + test.name + " " , type: .string)
    constantVals.saveToVals(address: testMessage.address, value: testMessage.name)
    
    let printTest = Quadruple(quadOperator: "PRINT", leftOperand: -1, rightOperand: testMessage.address, result: -1)
    arrayQuads.append(printTest)
    
    let endFail = Quadruple(quadOperator: "END", leftOperand: -1, rightOperand: -1, result: -1)
    arrayQuads.append(endFail)
}

/**
 * This class provides an empty implementation of {@link tddListener},
 * which can be extended to create a listener which only needs to handle a subset
 * of the available methods.
 */
open class tddBaseListener: tddListener {
    
    public var documentation = "# Documentation \n"
    public var outputs = ""
    public var runTests = false
    public var inputs = [Any]()

     public init() { }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterProgram(_ ctx: tddParser.ProgramContext) {
        if error {
            return
        }
        scope = "global"
        let function = Function(name: scope, type: .int, scope: scope)
        symbols.insert(function: function)
        //Instert jump to main
        let jumtToMain = Quadruple(quadOperator: "GOTO", leftOperand: -1, rightOperand: -1, result: -1)
        arrayQuads.append(jumtToMain)
        
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitProgram(_ ctx: tddParser.ProgramContext) {
        if error {
              return
          }
        let testInp = Quadruple(quadOperator: "TEST", leftOperand: -1, rightOperand: -1, result: -1)
        arrayQuads.append(testInp)
        for test in tests {
            genQuadTest(test: test)
        }
        testInp.fillMissingResult(result: arrayQuads.count)
        let endProg = Quadruple(quadOperator: "END", leftOperand: -1, rightOperand: -1, result: -1)
        arrayQuads.append(endProg)
        localMemory.clean()
        print("QUADRUPLOS")
        for (index, quad) in arrayQuads.enumerated() {
            guard let oper = quad.quadOperator, let left = quad.leftOperand, let right = quad.rightOperand, let res = quad.result else {
                return
            }
            print("\(index): operator \(oper) left: \(left) right \(right) result: \(res)")
        }
        
        print(documentation)
        for index in 0..<inputs.count {
            if let input = (inputs[index] as? String) {
            let type = findType(value: input)
            switch type {
            case .int:
                inputs[index] = Int(input)!
            case .float:
                inputs[index] = Double(input)!
            case .string:
                inputs[index] = input
            case .bool:
                inputs[index] = input == "true"
            case .char:
                inputs[index] = input.first!
            default:
                print("Error parsing inputs")
                }
            }
        }
        //Temporal VM test
        let vm = VirtualMachine(quadruples: arrayQuads, constantMemory: constantVals, sReads: inputs , testInputs: runTests , outputs: outputs)
        vm.execute()
        outputs = vm.outputs
        arrayQuads = []
        tests = []
        
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterFunction(_ ctx: tddParser.FunctionContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitFunction(_ ctx: tddParser.FunctionContext) {
        if error {
              return
          }
        let endProc = Quadruple(quadOperator: "ENDPROC", leftOperand: -1, rightOperand: -1, result: -1)
        arrayQuads.append(endProc)
        localMemory.clean()
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterHeader(_ ctx: tddParser.HeaderContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitHeader(_ ctx: tddParser.HeaderContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterHeader_body(_ ctx: tddParser.Header_bodyContext) {
        if error {
              return
          }
        guard let description = ctx.DESCRIPTION() else {
                return
        }
        var functionName = ""
        let params = ctx.param()
        let tests = ctx.test()
        if (ctx.parent?.parent as? tddParser.FunctionContext) != nil {
            let functionContext = ctx.parent?.parent as! tddParser.FunctionContext
            if functionContext.function_dec() == nil {
                functionName = functionContext.void_function_dec()!.ID()!.getText()
            } else {
            functionName = functionContext.function_dec()!.ID()!.getText()
            }
            documentation.append("## \(functionName) \n")
            documentation.append("\(description.getText()[3..<description.getText().count]) \n")
        }
        docCurrFunName = functionName
        if params.count > 0 {
            documentation.append("### Parameters: \n")
            documentation.append("| Type | Name | Description | \n")
            documentation.append("| --- | --- | --- | \n")
        }
        for param in params {
            let description: String = param.DESCRIPTION()!.getText()
            documentation.append("| \(param.TYPE()!.getText()) | \(param.ID()!.getText()) | \(description[3..<description.count]) | \n")
        }
        
        guard let returnTests = ctx.return_test() else {
            return
        }
        
        // Append test related stuff
        let testDescription = returnTests.DESCRIPTION()!.getText()
        documentation.append("### Returns \n")
        documentation.append("| Type | Description | \n")
        documentation.append("| --- | --- | \n")
        documentation.append("| \(returnTests.TYPE()!.getText()) | \(testDescription[3..<testDescription.count]) | \n")
        
        if tests.count > 0 {
            documentation.append("## Tests \n")
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitHeader_body(_ ctx: tddParser.Header_bodyContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterParam(_ ctx: tddParser.ParamContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitParam(_ ctx: tddParser.ParamContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterReturn_test(_ ctx: tddParser.Return_testContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitReturn_test(_ ctx: tddParser.Return_testContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterTest(_ ctx: tddParser.TestContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitTest(_ ctx: tddParser.TestContext) {
        if error {
              return
          }
            var testParams = [String]()
        if ctx.test_inputs() != nil {
                var child = ctx.test_inputs()
                while child != nil {
                    let inputContext = child as! tddParser.Test_inputsContext
                    testParams.append(inputContext.VALUE()!.getText())
                    child = child?.test_inputs()
            }
        }
        if testParams.count > 0 {
            documentation.append("- **\(docCurrFunName)**(")
        }
        var params = [String]()
        var test = Test(name: docCurrFunName, params: params, returnVal: "0")
        for (index, param) in testParams.enumerated() {
            if index == testParams.count - 1 {
                documentation.append("\(param)) => \(ctx.VALUE()!.getText())\n")
                params.append(param)
                test.returnVal = ctx.VALUE()!.getText()
            } else {
                documentation.append("\(param),")
                params.append(param)
                
            }
        }
        test.params = params
        tests.append(test)

    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterTest_inputs(_ ctx: tddParser.Test_inputsContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitTest_inputs(_ ctx: tddParser.Test_inputsContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterFunction_dec(_ ctx: tddParser.Function_decContext) {
        if error {
              return
          }
        guard let functionName = ctx.ID()?.getText(), let typeText = ctx.TYPE()?.getText() else {
            print("error")
            return
        }
        scope = functionName
        // TODO: Solve address to a real one
        let function = Function(name: functionName, type: Type(type: typeText), scope: scope)
        symbols.insert(function: function)
        
        let globalFuncVariable = createVariable(memory: globalMemory, id: function.name, type: function.type)
        function.setReturnAddress(address: globalFuncVariable.address)
        symbols.functionsDictionary["global"]?.variables.append(globalFuncVariable)
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitFunction_dec(_ ctx: tddParser.Function_decContext) {
        if error {
              return
          }
        let function = symbols.functionsDictionary[scope]!
        function.fillInitialQuad(start_quadruple: arrayQuads.count)
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterVoid_function_dec(_ ctx: tddParser.Void_function_decContext) {
        if error {
              return
          }
        guard let functionName = ctx.ID()?.getText() else {
            // TODO: Some type of error
            return
        }
        scope = functionName
        let function = Function(name: functionName, type: .void, scope: scope)
        symbols.insert(function: function)
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitVoid_function_dec(_ ctx: tddParser.Void_function_decContext) {
        let function = symbols.functionsDictionary[scope]!
        function.fillInitialQuad(start_quadruple: arrayQuads.count)
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterInputs(_ ctx: tddParser.InputsContext) {
        if error {
              return
          }
        // Var nam
        guard let name = ctx.ID()?.getText(), let type = ctx.TYPE()?.getText() else {
            // TODO: Handle possible error
            return
        }
        if ctx.array_dimension_dec() == nil && ctx.matrix_dimension_dec() == nil {
            let variable = createVariable(memory: localMemory, id: name, type: Type(type: type), input: true)
            symbols.functionsDictionary[scope]?.variables.append(variable)
            symbols.functionsDictionary[scope]?.addInput()
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitInputs(_ ctx: tddParser.InputsContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterBody(_ ctx: tddParser.BodyContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitBody(_ ctx: tddParser.BodyContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterReturn_statement(_ ctx: tddParser.Return_statementContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitReturn_statement(_ ctx: tddParser.Return_statementContext) {
        if error {
              return
          }
        let function = symbols.functionsDictionary[scope]
        if (sTypes.first! != function?.type) {
            print("Return type does not match function")
        }
        let newQuad = Quadruple(quadOperator: "RETURN", leftOperand: sOperands.first!, rightOperand: -1, result: function!.return_address)
        arrayQuads.append(newQuad)
        sOperands.removeFirst()
        sTypes.removeFirst()
        temporalMemory.clean()
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterMain(_ ctx: tddParser.MainContext) {
        if error {
              return
          }
        scope = "main"
        let function = Function(name: scope, type: .void, scope: scope)
        symbols.insert(function: function)
        //Solve jump to Main
        arrayQuads[0].fillMissingResult(result: arrayQuads.count)
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitMain(_ ctx: tddParser.MainContext) {
        if error {
              return
          }
        let function = symbols.functionsDictionary[scope]!
        function.fillInitialQuad(start_quadruple: arrayQuads.count)
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterVariable(_ ctx: tddParser.VariableContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitVariable(_ ctx: tddParser.VariableContext) {
       if error {
             return
         }
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterNon_atomic(_ ctx: tddParser.Non_atomicContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitNon_atomic(_ ctx: tddParser.Non_atomicContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterNa_declaration(_ ctx: tddParser.Na_declarationContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitNa_declaration(_ ctx: tddParser.Na_declarationContext) {
        if error {
              return
          }
        
        var parent = ctx.parent
               while(!((parent as? tddParser.Non_atomicContext) != nil)) {
                   parent = parent?.parent
               }
               guard let type = (parent as! tddParser.Non_atomicContext).TYPE(), let id = ctx.ID() else {
                   print("error")
                   return
               }
        let variable: Variable!
        var size = 1
        var x: Int = 1
        var y: Int = 1

        if let arrayDimenInfo = ctx.children![1] as? tddParser.Array_dimension_decContext {
            x = Int(arrayDimenInfo.VALUE()!.getText()) ?? 1
            size = x
        } else if let matrixDimenInfo = ctx.children![1] as? tddParser.Matrix_dimension_decContext {
            x = Int(matrixDimenInfo.VALUE()[0].getText()) ?? 1
            y = Int(matrixDimenInfo.VALUE()[1].getText()) ?? 1
            size = x * y

        }
               if scope == "global" {
                variable = createVariable(memory: globalMemory, id: id.getText(), type: Type(type: type.getText()), size: size, dimensionated: true, x: x, y: y)
               } else {
                variable = createVariable(memory: localMemory, id: id.getText(), type: Type(type: type.getText()), size: size, dimensionated: true, x: x, y: y)
               }
               symbols.functionsDictionary[scope]?.variables.append(variable)
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterArray_dimension_dec(_ ctx: tddParser.Array_dimension_decContext) {
        if error {
              return
          }
        print(ctx.getText())
        print(ctx.VALUE()!)
        let value = ctx.VALUE()!.getText()
        let variable = createVariable(memory: constantMemory, id: value, type: .int)
        constantVals.saveToVals(address: variable.address, value: ctx.VALUE()!.getText())
        //For array input declaration
        if let inputParent = ctx.parent as? tddParser.InputsContext {
            let variable: Variable!
            let size = Int(value)!
            let x: Int = size
            
            guard let type = inputParent.TYPE(), let id = inputParent.ID() else {
                print("error")
                return
            }

            if scope == "global" {
                variable = createVariable(memory: globalMemory, id: id.getText(), type: Type(type: type.getText()), input: true, size: size, dimensionated: true, x: x)
            } else {
                variable = createVariable(memory: localMemory, id: id.getText(), type: Type(type: type.getText()), input: true, size: size, dimensionated: true, x: x)
            }
            symbols.functionsDictionary[scope]?.variables.append(variable)
            symbols.functionsDictionary[scope]?.addInput()
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitArray_dimension_dec(_ ctx: tddParser.Array_dimension_decContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterMatrix_dimension_dec(_ ctx: tddParser.Matrix_dimension_decContext) {
        if error {
              return
          }
        let value1 = ctx.VALUE()[0].getText()
        let value2 = ctx.VALUE()[1].getText()
        
        let var1 = createVariable(memory: constantMemory, id: value1, type: .int)
        let var2 = createVariable(memory: constantMemory, id: value2, type: .int)
        
        constantVals.saveToVals(address: var1.address, value: value1)
        
        constantVals.saveToVals(address: var2.address, value: value2)
        
        //For matrix input declaration
        if let inputParent = ctx.parent as? tddParser.InputsContext {
            
            let variable: Variable!
            let x: Int = Int(value1)!
            let y: Int = Int(value2)!
            let size : Int = x*y
            
            guard let type = inputParent.TYPE(), let id = inputParent.ID() else {
                print("error")
                return
            }

            if scope == "global" {
                variable = createVariable(memory: globalMemory, id: id.getText(), type: Type(type: type.getText()), input: true, size: size, dimensionated: true, x: x, y: y)
            } else {
                variable = createVariable(memory: localMemory, id: id.getText(), type: Type(type: type.getText()), input: true, size: size, dimensionated: true, x: x, y: y)
            }
            symbols.functionsDictionary[scope]?.variables.append(variable)
            symbols.functionsDictionary[scope]?.addInput()
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitMatrix_dimension_dec(_ ctx: tddParser.Matrix_dimension_decContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterArray_dimension(_ ctx: tddParser.Array_dimensionContext) {
        if error {
              return
          }
        solvingDimen = .array


    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitArray_dimension(_ ctx: tddParser.Array_dimensionContext) {
        if error {
              return
          }
        
        print(ctx.getText())
        // Crear cuadruplo de VER
        let indexAddress = sOperands.first!
        // TODO: Get real address for array (Sumarle el desplazamiento)
        let verQuad = Quadruple(quadOperator: "VER", leftOperand: indexAddress, rightOperand: 0, result: pendingArrayAddresses.first!.x)
        sOperands.removeFirst()
        sTypes.removeFirst()
        arrayQuads.append(verQuad)
        // Use formula x + DirBase to get address
        let tmpAddress = -1 * createTemp(type: .int)
        let addQuad = Quadruple(quadOperator: "+arr", leftOperand: indexAddress, rightOperand: pendingArrayAddresses.first!.address, result: tmpAddress)
        arrayQuads.append(addQuad)
        sOperands.insert(tmpAddress, at: 0)
        sTypes.insert(pendingArrayAddresses.first!.type, at:0)
        pendingArrayAddresses.removeFirst()
        solvingDimen = .none
        
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterMatrix_dimension(_ ctx: tddParser.Matrix_dimensionContext) {
        if error {
              return
          }
        solvingDimen = .matrix
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitMatrix_dimension(_ ctx: tddParser.Matrix_dimensionContext) {
        if error {
              return
          }
        print(ctx.getText())
        // Crear primer cuadruplo de VER
        let indexAddress = sOperands.first!
        // TODO: Get real address for array (Sumarle el desplazamiento)
        let verQuad = Quadruple(quadOperator: "VER", leftOperand: indexAddress, rightOperand: 0, result: pendingArrayAddresses.first!.y)
        sOperands.removeFirst()
        sTypes.removeFirst()
               arrayQuads.append(verQuad)
        
        
        let indexAddress2 = sOperands.first!
        let verQuad2 = Quadruple(quadOperator: "VER", leftOperand: indexAddress2, rightOperand: 0, result: pendingArrayAddresses.first!.x)
        arrayQuads.append(verQuad2)
        sOperands.removeFirst()
        sTypes.removeFirst()
        
        // Use formula x * d2 + y + DirBase to get address
        
        let x = indexAddress2
        let y = indexAddress
        let d2 = pendingArrayAddresses.first!.y
        let dirBase = pendingArrayAddresses.first!.address
        let tmp1 = createTemp(type: .int)
        let multQuad = Quadruple(quadOperator: "*", leftOperand: constantVals.getAddressForVal(val: d2), rightOperand: x, result: tmp1)
        
        arrayQuads.append(multQuad)
        
        let tmp2 = createTemp(type: .int)
        let addQuad = Quadruple(quadOperator: "+", leftOperand: tmp1, rightOperand: y, result: tmp2)
        arrayQuads.append(addQuad)
        
        let tmp3 = -1 * createTemp(type: .int)
        let addQuad2 = Quadruple(quadOperator: "+arr", leftOperand: tmp2, rightOperand: dirBase, result: tmp3)
        arrayQuads.append(addQuad2)
        sOperands.insert(tmp3, at: 0)
        sTypes.insert(pendingArrayAddresses.first!.type, at: 0)
        pendingArrayAddresses.removeFirst()
        solvingDimen = .none
        
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterVar_declaration(_ ctx: tddParser.Var_declarationContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitVar_declaration(_ ctx: tddParser.Var_declarationContext) {
        if error {
              return
          }
        
        // Var name
        var parent = ctx.parent
        while(!((parent as? tddParser.VariableContext) != nil)) {
            parent = parent?.parent
        }
        guard let type = (parent as! tddParser.VariableContext).TYPE(), let id = ctx.ID() else {
            print("error")
            return
        }
        let variable: Variable!
        if scope == "global" {
            variable = createVariable(memory: globalMemory, id: id.getText(), type: Type(type: type.getText()))
        } else {
               variable = createVariable(memory: localMemory, id: id.getText(), type: Type(type: type.getText()))
        }
        symbols.functionsDictionary[scope]?.variables.append(variable)
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterStatement(_ ctx: tddParser.StatementContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitStatement(_ ctx: tddParser.StatementContext) {
        if error {
              return
          }}
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterSuper_condition_check(_ ctx: tddParser.Super_condition_checkContext) {
        if error {
              return
          }
    }
    
    open func exitSuper_condition_check(_ ctx: tddParser.Super_condition_checkContext) {
        if error {
              return
          }
        sTypes.removeFirst()
        sOperands.removeFirst()
        temporalMemory.clean()
        let quad = Quadruple.init(quadOperator: "GOTOF", leftOperand: arrayQuads[arrayQuads.count-1].result, rightOperand: -1, result: -1)
        arrayQuads.append(quad)
        sJumps.insert(arrayQuads.count - 1, at: 0)
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterCondition_check(_ ctx: tddParser.Condition_checkContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitCondition_check(_ ctx: tddParser.Condition_checkContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterCondition(_ ctx: tddParser.ConditionContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitCondition(_ ctx: tddParser.ConditionContext) {
        if error {
              return
          }
        //Solve previous quad
        if(!sJumps.isEmpty) {
            solveQuad()
        }
        //Solve all GOTO
        while(!sGoto.isEmpty) {
            arrayQuads[sGoto.first!].fillMissingResult(result: arrayQuads.count)
            sGoto.removeFirst()
        }
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterElse_if_condition(_ ctx: tddParser.Else_if_conditionContext) {
        if error {
              return
          }
        //Generate GOTO
        let quad = Quadruple.init(quadOperator: "GOTO", leftOperand: -1, rightOperand: -1, result: -1)
        arrayQuads.append(quad)
        sGoto.insert(arrayQuads.count - 1, at: 0)
        //Solve previous quad
        if(!sJumps.isEmpty) {
            solveQuad()
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitElse_if_condition(_ ctx: tddParser.Else_if_conditionContext) {
        if error {
              return
          }
        //Solve previous quad
        if(!sJumps.isEmpty) {
            solveQuad()
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterElse_condition(_ ctx: tddParser.Else_conditionContext) {
        if error {
              return
          }
        //Generate GOTO
        let quad = Quadruple.init(quadOperator: "GOTO", leftOperand: -1, rightOperand: -1, result: -1)
        arrayQuads.append(quad)
        sGoto.insert(arrayQuads.count - 1, at: 0)
        //Solve previous quad
        if(!sJumps.isEmpty) {
            solveQuad()
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitElse_condition(_ ctx: tddParser.Else_conditionContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterHiper_expresion(_ ctx: tddParser.Hiper_expresionContext) {
        if error {
              return
          }
        //Check for opening parenthesis
        if let parent = ctx.parent as? tddParser.FactorContext {
            if parent.OPEN_PAR() != nil {
                sOperators.insert("(", at: 0)
            }
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitHiper_expresion(_ ctx: tddParser.Hiper_expresionContext) {
        if error {
              return
          }
        //Check for closing parenthesis
        if let parent = ctx.parent as? tddParser.FactorContext {
            if parent.CLOSE_PAR() != nil && sOperators.first == "(" {
                sOperators.removeFirst()
            }
            else {
                // TODO: Report  error
                return
            }
        }

     if pendingArrayAddresses.isEmpty {
        if let oper = ctx.AND()?.getText() {
            sOperators.insert(oper, at:0)
            // Create Quadruple
            let newQuad = createQuad()
             arrayQuads.append(newQuad)

        }
        else if let oper = ctx.OR()?.getText() {
            sOperators.insert(oper, at:0)
            let newQuad = createQuad()
             arrayQuads.append(newQuad)
        }}
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterExpresion(_ ctx: tddParser.ExpresionContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitExpresion(_ ctx: tddParser.ExpresionContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterExp(_ ctx: tddParser.ExpContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitExp(_ ctx: tddParser.ExpContext) {
        if error {
              return
          }
        if (!sOperators.isEmpty && pendingArrayAddresses.isEmpty) {
            if(sOperators.first! == "==" || sOperators.first! == "!=" || sOperators.first! == "<" || sOperators.first! == ">" || sOperators.first! == "<=" || sOperators.first! == ">=") {
                let newQuad = createQuad()
                arrayQuads.append(newQuad)
            }
        }
        if let parent = ctx.parent as? tddParser.ExpresionContext {
            if let oper = parent.EQUALITY()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.DIFFERENT()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.LESS_THAN()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.GREATER_THAN()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.LESS_EQUAL()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.GREATER_EQUAL()?.getText() {
                sOperators.insert(oper, at:0)
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterTermino(_ ctx: tddParser.TerminoContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitTermino(_ ctx: tddParser.TerminoContext) {
        if error {
              return
          }
        if (!sOperators.isEmpty && solvingDimen == .none) {
            //TODO gen quadruple with sOperators.first!
            if(sOperators.first! == "+" || sOperators.first! == "-") {
               let newQuad = createQuad()
                arrayQuads.append(newQuad)

            }
        }
        if let parent = ctx.parent as? tddParser.ExpContext {
            if let oper = parent.ADD()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.SUBSTRACT()?.getText() {
                sOperators.insert(oper, at:0)
            }
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterFactor(_ ctx: tddParser.FactorContext) {
        if error {
              return
          }
        //Check for ID
        if let id = ctx.ID()?.getText() {
            guard let variable = symbols.findID(scope: scope, id: id) else {
                //Compile error var does not exist
                return
            }
            
            if (variable.dimensionated  && (ctx.array_dimension() != nil
                || ctx.matrix_dimension() != nil)){
                pendingArrayAddresses.append(variable)
            } else {
                sOperands.insert(variable.address, at:0)
                sTypes.insert(variable.type, at:0)
            }
        }
        //Check for negative constant
        else if ctx.SUBSTRACT()?.getText() != nil {
            guard let value = ctx.VALUE()?.getText() else {
                // TODO: Error
                return
            }
            let variable = createVariable(memory: constantMemory, id: "-\(value)", type: findType(value: value))
            constantVals.saveToVals(address: variable.address, value: variable.name)
            sOperands.insert(variable.address, at:0)
            sTypes.insert(variable.type, at:0)
        }
        //Check for constant
        else if let value = ctx.VALUE()?.getText() {
            let variable = createVariable(memory: constantMemory, id: value, type: findType(value: value))
            constantVals.saveToVals(address: variable.address, value: variable.name)
            sOperands.insert(variable.address, at:0)
            sTypes.insert(variable.type, at:0)
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitFactor(_ ctx: tddParser.FactorContext) {
        if error {
              return
          }
        if (!sOperators.isEmpty) {
            //TODO gen quadruple with sOperators.first!
            if((sOperators.first! == "*" || sOperators.first! == "/") && solvingDimen == .none) {
               let newQuad = createQuad()
                arrayQuads.append(newQuad)

            }
        }
        if let parent = ctx.parent as? tddParser.TerminoContext {
            if let oper = parent.MULTIPLY()?.getText() {
                sOperators.insert(oper, at:0)
            }
            else if let oper = parent.DIVIDE()?.getText() {
                sOperators.insert(oper, at:0)
            }
        }
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterFunction_hiper_expresions(_ ctx: tddParser.Function_hiper_expresionsContext) {
        if error {
              return
          }
        //Function with return call starts
        print(ctx.getText())
        if let parent = ctx.parent as? tddParser.FactorContext {
            sOperators.insert("(", at: 0)
            sfunction_param_index.insert(0, at: 0)
            let function_name = parent.ID()?.getText()
            let function = symbols.functionsDictionary[function_name!]
            if  function != nil && function?.type != .void{
                sFunctions.insert(function!, at: 0)
                let newQuad = Quadruple(quadOperator: "ERA", leftOperand: function!.start_quadruple, rightOperand: -1, result: -1)
                arrayQuads.append(newQuad)
            }
            else {
                print("Not a return function")
            }
        }
        //Void function call starts
        else if let parent = ctx.parent as? tddParser.Void_func_callContext {
            sOperators.insert("(", at: 0)
            sfunction_param_index.insert(0, at: 0)
            let function_name = parent.ID()?.getText()
            let function = symbols.functionsDictionary[function_name!]
            if  function != nil && function?.type == .void {
                sFunctions.insert(function!, at: 0)
                let newQuad = Quadruple(quadOperator: "ERA", leftOperand: function!.start_quadruple, rightOperand: -1, result: -1)
                arrayQuads.append(newQuad)
            }
            else {
                print("Not a void function")
            }
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitFunction_hiper_expresions(_ ctx: tddParser.Function_hiper_expresionsContext) {
        if error {
              return
          }
        //Function call ends
        if let parent = ctx.parent as? tddParser.FactorContext {
            //First or unique parameter is going to be processed last
            if (sOperands.count > 0 && sTypes.count > 0) {
                let paramQuad = addParamQuad()
                arrayQuads.append(paramQuad)
                sfunction_param_index[0] = sfunction_param_index[0] + 1
            }
            let function = sFunctions.first!
            sFunctions.removeFirst()
            
            if (sfunction_param_index.first! < function.input_total) {
                message += "Too few arguments error\n"
                error = true
                print("ERROR too few arguments")
                return
            }
            sfunction_param_index.removeFirst() //Reset params count
            
            let subQuad = Quadruple(quadOperator: "GOSUB", leftOperand: function.start_quadruple, rightOperand: -1, result: -1)
            arrayQuads.append(subQuad)
            
            //Remove from sOperands ID of function
            sOperands.removeFirst()
            sTypes.removeFirst()
            
            let tempReturn = createTemp(type: function.type)
            let returnQuad = Quadruple(quadOperator: "=", leftOperand: function.return_address, rightOperand: -1, result: tempReturn)
            arrayQuads.append(returnQuad)
            
            sOperands.insert(tempReturn, at: 0)
            sTypes.insert(function.type, at: 0)
            sOperators.removeFirst() //Remove last )
        }
        else if let parent = ctx.parent as? tddParser.Void_func_callContext {
            //First or unique parameter is going to be processed last
            if (sOperands.count > 0 && sTypes.count > 0) {
                let paramQuad = addParamQuad()
                arrayQuads.append(paramQuad)
                sfunction_param_index[0] = sfunction_param_index[0] + 1
            }
            let function = sFunctions.first!
            sFunctions.removeFirst()
            
            if (sfunction_param_index.first! < function.input_total) {
                print("ERROR too few arguments")
                message += "Too few arguments error\n"
                error = true
                return
            }
            sfunction_param_index.removeFirst() //Reset params count
            
            let subQuad = Quadruple(quadOperator: "GOSUB", leftOperand: function.start_quadruple, rightOperand: -1, result: -1)
            arrayQuads.append(subQuad)
            
            sOperators.removeFirst()//Remove last )
            temporalMemory.clean()
        }
        //Reading 2nd to nth function param are going to be processed first
        else if sfunction_param_index.first! >= 0 {
            let paramQuad = addParamQuad()
            arrayQuads.append(paramQuad)
            sfunction_param_index[0] = sfunction_param_index[0] + 1
        }
        else {
            print("ERROR")
        }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterPrint(_ ctx: tddParser.PrintContext) {
        if error {
              return
          }
        
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    /*
     * In charge of creating a cuadruple for printing,
     * the quad looks like: ("PRINT", -1, ADDRESS, -1);
     */
    open func exitPrint(_ ctx: tddParser.PrintContext) {
        if error {
              return
          }
        // Ignore type of printing because  everything is printable
        sTypes.removeFirst()
        let printOperand = sOperands.first!
        sOperands.removeFirst()
        temporalMemory.clean()
        let newQuad = Quadruple(quadOperator: "PRINT", leftOperand: -1, rightOperand: printOperand, result: -1)
        arrayQuads.append(newQuad)
        
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterAlgo_imprimible(_ ctx: tddParser.Algo_imprimibleContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitAlgo_imprimible(_ ctx: tddParser.Algo_imprimibleContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterAsignation(_ ctx: tddParser.AsignationContext) {
        if error {
              return
          }
        if let arrayInfo = ctx.array_dimension() {
            if let id = ctx.ID()?.getText() {
                guard let variable = symbols.findID(scope: scope, id: id) else {
                           //Compile error var does not exist
                           return
                       }
                pendingArrayAddresses.append(variable)            }
        } else if let matrixInfo = ctx.matrix_dimension() {
            if let id = ctx.ID()?.getText() {
                    guard let variable = symbols.findID(scope: scope, id: id) else {
                                //Compile error var does not exist
                                return
                            }
                    pendingArrayAddresses.append(variable)
               }
        }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitAsignation(_ ctx: tddParser.AsignationContext) {
        if error {
              return
          }
        var value : Int
        var valueType : Type
        if (ctx.READ() == nil) {
            value = sOperands.first!
            sOperands.removeFirst()
            valueType = sTypes.first!
            sTypes.removeFirst()
        }
        else {
            valueType = Type(type: (ctx.TYPE()?.getText())!)
            value = createTemp(type: valueType)
            let readQuad = Quadruple(quadOperator: "READ", leftOperand: -1, rightOperand: -1, result: value)
            arrayQuads.append(readQuad)
        }
        
        var variableToAsign : Int
        var varType : Type
        var newQuad : Quadruple
        if (ctx.array_dimension() == nil && ctx.matrix_dimension() == nil ) {
            let variable = symbols.findID(scope: scope, id: ctx.ID()!.getText())!
            variableToAsign = variable.address
            varType = variable.type
        }
        else {
            //IS array
            variableToAsign = sOperands.first!
            sOperands.removeFirst()
            varType = sTypes.first!
            sTypes.removeFirst()
        }
        
        if !semanticCube.checkCube(currOperator: "=", leftType: valueType, rightType: varType) {
            // TODO: Handle semantic cube error
            return
        }
        
        temporalMemory.clean()
        newQuad = Quadruple(quadOperator: "=", leftOperand: value, rightOperand: -1, result: variableToAsign)
        arrayQuads.append(newQuad)
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterWhile_loop(_ ctx: tddParser.While_loopContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitWhile_loop(_ ctx: tddParser.While_loopContext) {
        if error {
              return
          }
        //Generate GOTO
        let quad = Quadruple.init(quadOperator: "GOTO", leftOperand: -1, rightOperand: -1, result: sJumps.first!-1)
        arrayQuads.append(quad)
        arrayQuads[sJumps.first!].fillMissingResult(result: arrayQuads.count)
        sJumps.removeFirst()
    }
    
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterVoid_func_call(_ ctx: tddParser.Void_func_callContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitVoid_func_call(_ ctx: tddParser.Void_func_callContext) {
        if error {
              return
          }
    }

    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func enterEveryRule(_ ctx: ParserRuleContext) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func exitEveryRule(_ ctx: ParserRuleContext) {
        if error {
              return
          }
        
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func visitTerminal(_ node: TerminalNode) {
        if error {
              return
          }
    }
    /**
     * {@inheritDoc}
     *
     * <p>The default implementation does nothing.</p>
     */
    open func visitErrorNode(_ node: ErrorNode) {
        if error {
              return
          }
    }
}
