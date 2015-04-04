import Foundation

class CalculatorBrain
{
    private enum Op : Printable
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case NoOperation(String, () -> Double)
        case Variable(String)
        var description : String{
            get{
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .NoOperation(let symbol, _):
                    return symbol
                case .Variable(let keyvar):
                    return keyvar
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    var variableValues = [String:Double]()
    
    private var knownOps = [String:Op] ()
    var opDone = false
    var descriprion: String{
        get{
            if !opDone{
                opDone = true
                return returnStringEval(opStack).result!
                }
            else{
                return ", " + returnStringEval(opStack).result!
            }
        }
    }
    typealias PropertyList = AnyObject
    var program: PropertyList{ // guaranteed to be a property list
        get{
            return opStack.map{ $0.description};
            }
        set{
            if let opSymbols = newValue as? Array<String>{
                var newOpStack = [Op]()
                for opSymbol in opSymbols{
                    if let op = knownOps[opSymbol]{
                    newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    init ()
    {
        func learnOp(op: Op)
        {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("✖️", *))
        learnOp(Op.BinaryOperation("➗") {$1 / $0})
        learnOp(Op.BinaryOperation("➕", +))
        learnOp(Op.BinaryOperation("➖") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.NoOperation("π", {M_PI}))

    }
    
    func clearStack(){
        opStack.removeAll(keepCapacity: false)
        opDone = false
    }
    
    private func returnStringEval(ops: [Op]) -> (result: String?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .UnaryOperation(_, let operation):
                let operandString = returnStringEval(remainingOps)
                if let operand = operandString.result {
                    return (op.description + "(" + operand + ")", operandString.remainingOps)
                }
                else{
                    return (op.description + "(" + "?" + ")", operandString.remainingOps)

                }
            case .BinaryOperation(_, let operation):
                let op1str = returnStringEval(remainingOps)
                if let operand1 = op1str.result {
                    let op2str = returnStringEval(op1str.remainingOps)
                    if let operand2 = op2str.result {
                        return ("(" + operand1 + op.description + operand2 + ")", op2str.remainingOps)
                    }
                    else{
                        return ("(" + operand1 + op.description + "?" + ")", op2str.remainingOps)

                    }
                }
            case .NoOperation(_, let operation):
                return (op.description, remainingOps)
            case .Variable(let keyvar):
                if let variableIsSet = variableValues[keyvar]{
                    return ("\(variableIsSet)", remainingOps)
                }
                else
                {
                    return (nil, remainingOps)
                }
            }
        }
        return (nil, ops)

    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .NoOperation(_, let operation):
                return (operation(), remainingOps)
            case .Variable(let keyvar):
                if let variableIsSet = variableValues[keyvar]{
                    return (variableIsSet, remainingOps)
                }
                else
                {
                    return (nil, remainingOps)
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    
    func pushVariable(symbol: String) -> Double?{
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
}