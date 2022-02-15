import 'dart:io';

///
///Author: YoungChan
///Date: 2020-03-12 22:27:58
///LastEditors: YoungChan
///LastEditTime: 2020-04-22 23:45:35
///Description: file content
///
enum AstNodeName {
  Identifier,
  PrefixedIdentifier,
  NumericLiteral,
  StringLiteral,
  BooleanLiteral,
  SetOrMapLiteral,
  MapLiteralEntry,
  ListLiteral,
  NamedExpression,
  MemberExpression,
  MethodInvocation,
  FieldDeclaration,
  Annotation,
  PropertyAccess,
  ArgumentList,
  IfStatement,
  ForStatement,
  SwitchStatement,
  SwitchCase,
  SwitchDefault,
  ReturnStatement,
  BlockStatement,
  FormalParameterList,
  SimpleFormalParameter,
  TypeName,
  ClassDeclaration,
  FunctionDeclaration,
  MethodDeclaration,
  VariableDeclarator,
  VariableDeclarationList,
  BinaryExpression,
  AssignmentExpression,
  FunctionExpression,
  PrefixExpression,
  AwaitExpression,
  ExpressionStatement,
  IndexExpression,
  Program
}

String astNodeNameValue(AstNodeName nodeName) =>
    nodeName.toString().split(".")[1];

///ast node base class
abstract class AstNode {
  late Map _ast;
  late String _type;

  AstNode({required Map ast, String? type}) {
    _ast = ast;
    if (type != null) {
      _type = type;
    } else {
      _type = ast['type'];
    }
  }

  String get type => _type;

  Map toAst();
}

class Identifier extends AstNode {
  String name;

  Identifier(this.name, {required Map ast}) : super(ast: ast);

  static Identifier? fromAst(Map? ast) {
    if(ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.Identifier)) {
      return Identifier(ast['name'], ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

/// grammar like (prefix.identifier), eg: People.name
class PrefixedIdentifier extends AstNode {
  String identifier;
  String prefix;

  PrefixedIdentifier(this.identifier, this.prefix, {required Map ast}) : super(ast: ast);

  static PrefixedIdentifier? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.PrefixedIdentifier)) {
      final name = Identifier.fromAst(ast['identifier'])?.name;
      final prefix = Identifier.fromAst(ast['prefix'])?.name;
      if (name != null && prefix != null) {
        return PrefixedIdentifier(name,
            prefix,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class StringLiteral extends AstNode {
  String value;

  StringLiteral(this.value, {required Map ast}) : super(ast: ast);

  static StringLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.StringLiteral)) {
      return StringLiteral(ast['value'], ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class NumericLiteral extends AstNode {
  num value;

  NumericLiteral(this.value, {required Map ast}) : super(ast: ast);

  static NumericLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.NumericLiteral)) {
      return NumericLiteral(ast['value'], ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class BooleanLiteral extends AstNode {
  bool value;

  BooleanLiteral(this.value, {required Map ast}) : super(ast: ast);

  static BooleanLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.BooleanLiteral)) {
      return BooleanLiteral(ast['value'], ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class MapLiteralEntry extends AstNode {
  String key;
  Expression value;

  MapLiteralEntry(this.key, this.value, {required Map ast}) : super(ast: ast);

  static MapLiteralEntry? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.MapLiteralEntry)) {
      return MapLiteralEntry(
          _parseStringValue(ast['key']), Expression(ast['value'], ast: {}),
          ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class MapLiteral extends AstNode {
  Map<String, Expression> elements;

  MapLiteral(this.elements, {required Map ast}) : super(ast: ast);

  static MapLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.SetOrMapLiteral)) {
      var astElements = ast['elements'] as List;
      Map<String, Expression> entries = {};
      for (var e in astElements) {
        var entry = MapLiteralEntry.fromAst(e);
        entries[entry?.key as String] = entry?.value as Expression;
      }
      return MapLiteral(entries, ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class ListLiteral extends AstNode {
  List<Expression> elements;

  ListLiteral(this.elements, {required Map ast}) : super(ast: ast);

  static ListLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.ListLiteral)) {
      var astElements = ast['elements'] as List;
      List<Expression> items = [];
      for (var e in astElements) {
        final item = Expression.fromAst(e);
        if (item != null) {
          items.add(item);
        }
      }
      return ListLiteral(items, ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class Annotation extends AstNode {
  String name;
  List<Expression> argumentList;

  Annotation(this.name, this.argumentList, {required Map ast}) : super(ast: ast);

  static Annotation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.Annotation)) {
      final name = Identifier.fromAst(ast['id'])?.name;
      if (name != null) {
        return Annotation(name,
          _parseArgumentList(ast['argumentList']),
          ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class MemberExpression extends AstNode {
  Expression object;
  String property;

  MemberExpression(this.object, this.property, {required Map ast}) : super(ast: ast);

  static MemberExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.MemberExpression)) {
      final property = Identifier.fromAst(ast['property'])?.name;
      final object = Expression.fromAst(ast['object']);
      if (object != null && property != null) {
        return MemberExpression(object,
            property,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class SimpleFormalParameter extends AstNode {
  TypeName paramType;
  String name;

  SimpleFormalParameter(this.paramType, this.name, {required Map ast}) : super(ast: ast);

  static SimpleFormalParameter? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.SimpleFormalParameter)) {
      final paramType = TypeName.fromAst(ast['paramType']);
      if (paramType != null) {
        return SimpleFormalParameter(
            paramType, ast['name'],
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class TypeName extends AstNode {
  String name;

  TypeName(this.name, {required Map ast}) : super(ast: ast);

  static TypeName? fromAst(Map? ast) {
    if (ast != null && ast['type'] == 'TypeName') {
      return TypeName(ast['name'], ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class BlockStatement extends AstNode {
  ///代码块中各表达式
  List<Expression> body;

  BlockStatement(this.body, {required Map ast}) : super(ast: ast);

  static BlockStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.BlockStatement)) {
      var astBody = ast['body'] as List;
      var bodies = <Expression>[];
      for (var arg in astBody) {
        final item = Expression.fromAst(arg);
        if (item != null) {
          bodies.add(item);
        }
      }
      return BlockStatement(bodies, ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class MethodDeclaration extends AstNode {
  String name;
  List<SimpleFormalParameter> parameterList;
  BlockStatement body;
  bool isAsync;
  MethodDeclaration(this.name, this.parameterList, this.body,
      {this.isAsync = false, required Map ast})
      : super(ast: ast);

  static MethodDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.MethodDeclaration)) {
      var parameters = <SimpleFormalParameter>[];
      if (ast['parameters'] != null &&
          ast['parameters']['parameterList'] != null) {
        var astParameters = ast['parameters']['parameterList'] as List;
        for (var arg in astParameters) {
          final item = SimpleFormalParameter.fromAst(arg);
          if (item != null) {
            parameters.add(item);
          }
        }
      }
      final name = Identifier.fromAst(ast['id'])?.name;
      final body = BlockStatement.fromAst(ast['body']);
      if (name != null && body != null) {
        return MethodDeclaration(name, parameters,
            body,
            isAsync: ast['isAsync'] as bool, ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class FunctionDeclaration extends AstNode {
  ///函数名称
  String name;
  FunctionExpression expression;

  FunctionDeclaration(this.name, this.expression, {required Map ast}) : super(ast: ast);

  static FunctionDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.FunctionDeclaration)) {
      final name = Identifier.fromAst(ast['id'])?.name;
      final expression = FunctionExpression.fromAst(ast['expression']);
      if (name != null && expression != null) {
        return FunctionDeclaration(name,
            expression,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() {
    return _ast;
  }
}

class MethodInvocation extends AstNode {
  Expression callee;
  List<Expression> argumentList = [];
  SelectAstClass selectAstClass;

  MethodInvocation(this.callee, this.argumentList, this.selectAstClass,
      {required Map ast})
      : super(ast: ast);

  static MethodInvocation? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.MethodInvocation)) {
      final callee = Expression.fromAst(ast['callee']);
      final argumentList = _parseArgumentList(ast['argumentList']);
      final selectAstClass = SelectAstClass.fromAst(ast['selectAstClass']);
      if (callee != null && selectAstClass != null) {
        return MethodInvocation(
            callee,
            argumentList,
            selectAstClass,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class NamedExpression extends AstNode {
  String label;
  Expression expression;

  NamedExpression(this.label, this.expression, {required Map ast}) : super(ast: ast);

  static NamedExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.NamedExpression)) {
      final name = Identifier.fromAst(ast['id'])?.name;
      final expression = Expression.fromAst(ast['expression']);
      if (name != null && expression != null) {
        return NamedExpression(name,
            expression,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class PrefixExpression extends AstNode {
  ///操作的变量名称
  String argument;

  ///操作符
  String operator;

  ///是否操作符前置
  bool prefix;

  PrefixExpression(this.argument, this.operator, this.prefix, {required Map ast})
      : super(ast: ast);

  static PrefixExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.PrefixExpression)) {
      final name = Identifier.fromAst(ast['argument'])?.name;
      if (name != null) {
        return PrefixExpression(name,
            ast['operator'], ast['prefix'] as bool,
            ast: ast);
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class VariableDeclarator extends AstNode {
  String name;
  Expression init;

  VariableDeclarator(this.name, this.init, {required Map ast}) : super(ast: ast);

  static VariableDeclarator? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.VariableDeclarator)) {
      final name = Identifier.fromAst(ast['id'])?.name;
      final init = Expression.fromAst(ast['init']);
      if (name != null && init != null) {
        return VariableDeclarator(
            name, init,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class VariableDeclarationList extends AstNode {
  String typeAnnotation;
  List<VariableDeclarator> declarationList;

  VariableDeclarationList(this.typeAnnotation, this.declarationList, {required Map ast})
      : super(ast: ast);

  static VariableDeclarationList? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.VariableDeclarationList)) {
      var astDeclarations = ast['declarations'] as List;
      var declarations = <VariableDeclarator>[];
      for (var arg in astDeclarations) {
        final item = VariableDeclarator.fromAst(arg);
        if (item != null) {
          declarations.add(item);
        }
      }
      final name = Identifier.fromAst(ast['typeAnnotation'])?.name;
      if (name != null) {
        return VariableDeclarationList(
            name, declarations,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class FieldDeclaration extends AstNode {
  VariableDeclarationList fields;
  List<Annotation> metadata;

  FieldDeclaration(this.fields, this.metadata, {required Map ast}) : super(ast: ast);

  static FieldDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.FieldDeclaration)) {
      var astMetadata = ast['metadata'] as List;
      var metadatas = <Annotation>[];
      for (var arg in astMetadata) {
        final item = Annotation.fromAst(arg);
        if (item != null) {
          metadatas.add(item);
        }
      }
      final field = VariableDeclarationList.fromAst(ast['fields']);
      if (field != null) {
        return FieldDeclaration(
            field, metadatas,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class FunctionExpression extends AstNode {
  ///函数参数
  List<SimpleFormalParameter> parameterList;
  BlockStatement body;

  ///是否异步函数
  bool isAsync;

  FunctionExpression(this.parameterList, this.body,
      {this.isAsync = false, required Map ast})
      : super(ast: ast);

  static FunctionExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.FunctionExpression)) {
      var astParameters = ast['parameters']['parameterList'] as List;
      var parameters = <SimpleFormalParameter>[];
      for (var p in astParameters) {
        final item = SimpleFormalParameter.fromAst(p);
        if (item != null) {
          parameters.add(item);
        }
      }

      final body = BlockStatement.fromAst(ast['body']);
      if (body != null) {
        return FunctionExpression(parameters, body,
            isAsync: ast['isAsync'] as bool, ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class BinaryExpression extends AstNode {
  ///运算符
  /// * +
  /// * -
  /// * *
  /// * /
  /// * <
  /// * >
  /// * <=
  /// * >=
  /// * ==
  /// * &&
  /// * ||
  /// * %
  /// * <<
  /// * |
  /// * &
  /// * >>
  ///
  String operator;

  ///左操作表达式
  Expression left;

  ///右操作表达式
  Expression right;

  BinaryExpression(this.operator, this.left, this.right, {required Map ast})
      : super(ast: ast);

  static BinaryExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.BinaryExpression)) {
      final left = Expression.fromAst(ast['left']);
      final right = Expression.fromAst(ast['right']);
      if (left != null && right != null) {
        return BinaryExpression(ast['operator'], left,
            right,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class AssignmentExpression extends AstNode {
  String operator;
  Expression left;
  Expression right;

  AssignmentExpression(this.operator, this.left, this.right, {required Map ast})
      : super(ast: ast);

  static AssignmentExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.AssignmentExpression)) {
      final left = Expression.fromAst(ast['left']);
      final right = Expression.fromAst(ast['right']);
      if (left != null && right != null) {
        return AssignmentExpression(_parseStringValue(ast['operater']),
            left, right,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class AwaitExpression extends AstNode {
  MethodInvocation expression;

  AwaitExpression(this.expression, {required Map ast}) : super(ast: ast);

  static AwaitExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.AwaitExpression)) {
      final expression = MethodInvocation.fromAst(ast['expression']);
      if (expression != null) {
        return AwaitExpression(expression, ast: ast);
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class ClassDeclaration extends AstNode {
  String name;
  String superClause;
  List<Expression> body;

  ClassDeclaration(this.name, this.superClause, this.body, {required Map ast})
      : super(ast: ast);

  static ClassDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.ClassDeclaration)) {
      var astBody = ast['body'] as List;
      var bodies = <Expression>[];
      for (var arg in astBody) {
        final item = Expression.fromAst(arg);
        if (item != null) {
          bodies.add(item);
        }
      }
      final name = Identifier.fromAst(ast['id'])?.name;
      final superClause = TypeName.fromAst(ast['superClause'])?.name;
      if (name != null && superClause != null) {
        return ClassDeclaration(name,
            superClause, bodies,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class IfStatement extends AstNode {
  ///判断条件
  BinaryExpression condition;

  ///true 执行代码块
  BlockStatement consequent;

  ///false 执行代码块
  BlockStatement alternate;

  IfStatement(this.condition, this.consequent, this.alternate, {required Map ast})
      : super(ast: ast);

  static IfStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.IfStatement)) {
      final condition = BinaryExpression.fromAst(ast['condition']);
      final consequent = BlockStatement.fromAst(ast['consequent']);
      final alternate = BlockStatement.fromAst(ast['alternate']);
      if (condition != null && consequent != null && alternate != null) {
        return IfStatement(
            condition,
            consequent,
            alternate,
            ast: ast);
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class ForStatement extends AstNode {
  ForLoopParts forLoopParts;
  BlockStatement body;

  ForStatement(this.forLoopParts, this.body, {required Map ast}) : super(ast: ast);

  static ForStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.ForStatement)) {
      final body = BlockStatement.fromAst(ast['body']);
      final forLoopParts = ForLoopParts.fromAst(ast['forLoopParts']);
      if (body != null && forLoopParts != null) {
        return ForStatement(forLoopParts, body, ast: ast);
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class ForLoopParts extends AstNode {
  static const String forPartsWithDeclarations = "ForPartsWithDeclarations";
  static const String forPartsWithExpression = "ForPartsWithExpression";
  static const String forEachPartsWithDeclaration =
      "ForEachPartsWithDeclaration";

  ///初始化定义的值
  VariableDeclarationList? variableList;

  ///初始化赋值的值
  AssignmentExpression? initialization;

  ///循环判断条件
  BinaryExpression? condition;

  ///循环步进值
  Expression? updater;

  //for...in... 遍历迭代的数据集合变量名称
  String? iterable;
  //for...in... 遍历迭代值
  String? loopVariable;

  ForLoopParts(
      { this.variableList,
       this.initialization,
       this.condition,
       this.updater,
       this.iterable,
       this.loopVariable,
      required Map ast})
      : super(ast: ast);

  static ForLoopParts? fromAst(Map? ast) {
    if (ast != null) {
      switch (ast['type']) {
        case forPartsWithDeclarations:
          var updaters = ast['updaters'] as List;
          return ForLoopParts(
            variableList: VariableDeclarationList.fromAst(ast['variableList']),
            condition: BinaryExpression.fromAst(ast['condition']),
            updater:
                updaters.isNotEmpty ? Expression.fromAst(updaters[0]) : null,
            ast: ast,
          );

        case forPartsWithExpression:
          var updaters = ast['updaters'] as List;

          return ForLoopParts(
            initialization: AssignmentExpression.fromAst(ast['initialization']),
            condition: BinaryExpression.fromAst(ast['condition']),
            updater:
                updaters.isNotEmpty ? Expression.fromAst(updaters[0]) : null,
            ast: ast,
          );

        case forEachPartsWithDeclaration:
          return ForLoopParts(
            iterable: Identifier.fromAst(ast['iterable'])?.name,
            loopVariable: Identifier.fromAst(ast['loopVariable']['id'])?.name, ast: {},
          );
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class SwitchStatement extends AstNode {
  Expression checkValue;
  List<SwitchCase> body;

  SwitchStatement(this.checkValue, this.body, {required Map ast}) : super(ast: ast);

  static SwitchStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.SwitchStatement)) {
      var list = ast['body'] as List;
      var caseList = <SwitchCase>[];
      for (var s in list) {
        final item = SwitchCase.fromAst(s);
        if (item != null) {
          caseList.add(item);
        }
      }

      final checkValue = Expression.fromAst(ast['checkValue']);
      if (checkValue != null) {
        return SwitchStatement(checkValue, caseList,
            ast: ast);
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class SwitchCase extends AstNode {
  Expression? condition;
  List<Expression> statements;
  bool isDefault;
  SwitchCase(this.condition, this.statements, this.isDefault, {required Map ast})
      : super(ast: ast);

  static SwitchCase? fromAst(Map? ast) {
    if (ast != null) {
      var statements = <Expression>[];
      var list = ast['statements'] as List;
      for (var s in list) {
        final item = Expression.fromAst(s);
        if (item != null) {
          statements.add(item);
        }
      }

      if (ast['type'] == astNodeNameValue(AstNodeName.SwitchCase)) {
        return SwitchCase(
            Expression.fromAst(ast['condition']), statements, false,
            ast: ast);
      } else if (ast['type'] == astNodeNameValue(AstNodeName.SwitchDefault)) {
        return SwitchCase(null, statements, true, ast: ast);
      } else {
        return null;
      }
    }
    return null;
  }
  @override
  Map toAst() => _ast;
}

class ReturnStatement extends AstNode {
  Expression? argument;

  ReturnStatement(this.argument, {required Map ast}) : super(ast: ast);

  static ReturnStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.ReturnStatement)) {
      final argument = Expression.fromAst(ast['argument']);
      if (argument != null) {
        return ReturnStatement(argument, ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class PropertyAccess extends AstNode {
  String name;
  Expression expression;

  PropertyAccess(this.name, this.expression, {required Map ast}) : super(ast: ast);

  static PropertyAccess? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.PropertyAccess)) {
      final name = Identifier.fromAst(ast['id'])?.name;
      final expression = Expression.fromAst(ast['expression']);
      if (name != null && expression != null) {
        return PropertyAccess(name,
            expression,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class IndexExpression extends AstNode {
  Expression target;
  Expression index;

  IndexExpression(this.target, this.index, {required Map ast}) : super(ast: ast);

  static IndexExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast['type'] == astNodeNameValue(AstNodeName.IndexExpression)) {
      final target = Expression.fromAst(ast['target']);
      final index = Expression.fromAst(ast['index']);
      if (target != null && index != null) {
        return IndexExpression(
            target, index,
            ast: ast);
      }
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

class Program extends AstNode {
  List<Expression> body;

  Program(this.body, {required Map ast}) : super(ast: ast);

  static Program? fromAst(Map? ast) {
    if (ast != null && ast['type'] == astNodeNameValue(AstNodeName.Program)) {
      var astBody = ast['body'] as List;
      var bodies = <Expression>[];
      for (var arg in astBody) {
        final item = Expression.fromAst(arg);
        if (item != null) {
          bodies.add(item);
        }
      }
      return Program(bodies, ast: ast);
    }
    return null;
  }

  @override
  Map toAst() => _ast;
}

///通用 ast node
class Expression extends AstNode {
  AstNode _expression;

  bool isProgram;
  bool isClassDeclaration;
  bool isIdentifier;
  bool isPrefixedIdentifier;
  bool isStringLiteral;
  bool isNumericLiteral;
  bool isBooleanLiteral;
  bool isListLiteral;
  bool isMapLiteral;
  bool isMethodInvocation;
  bool isMemberExpression;
  bool isNamedExpression;
  bool isVariableDeclarationList;
  bool isBinaryExpression;
  bool isAssignmentExpression;
  bool isPropertyAccess;
  bool isMethodDeclaration;
  bool isReturnStatement;
  bool isFieldDeclaration;
  bool isFunctionExpression;
  bool isBlockStatement;
  bool isFunctionDeclaration;
  bool isAwaitExpression;
  bool isPrefixExpression;
  bool isExpressionStatement;
  bool isIfStatement;
  bool isForStatement;
  bool isSwitchStatement;
  bool isIndexExpression;

  @override
  Map toAst() => _ast;

  Expression(
    this._expression, {
    this.isProgram = false,
    this.isIdentifier = false,
    this.isPrefixedIdentifier = false,
    this.isStringLiteral = false,
    this.isNumericLiteral = false,
    this.isBooleanLiteral = false,
    this.isListLiteral = false,
    this.isMapLiteral = false,
    this.isMethodInvocation = false,
    this.isMemberExpression = false,
    this.isNamedExpression = false,
    this.isVariableDeclarationList = false,
    this.isBinaryExpression = false,
    this.isAssignmentExpression = false,
    this.isPropertyAccess = false,
    this.isClassDeclaration = false,
    this.isMethodDeclaration = false,
    this.isReturnStatement = false,
    this.isFieldDeclaration = false,
    this.isFunctionExpression = false,
    this.isBlockStatement = false,
    this.isFunctionDeclaration = false,
    this.isAwaitExpression = false,
    this.isPrefixExpression = false,
    this.isExpressionStatement = false,
    this.isIfStatement = false,
    this.isForStatement = false,
    this.isSwitchStatement = false,
    this.isIndexExpression = false,
    required Map ast,
  }) : super(ast: ast);

  static Expression? fromAst(Map? ast) {
    if (ast == null) return null;
    var astType = ast['type'];
    if (astType == astNodeNameValue(AstNodeName.Program)) {
      final expression = Program.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isProgram: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.ExpressionStatement)) {
      final expression = Expression.fromAst(ast['expression']);
      if (expression != null) {
        return Expression(expression, isExpressionStatement: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.Identifier)) {
      final expression = Identifier.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isIdentifier: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.PrefixedIdentifier)) {
      final expression = PrefixedIdentifier.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isPrefixedIdentifier: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.StringLiteral)) {
      final expression = StringLiteral.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isStringLiteral: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.NumericLiteral)) {
      final expression = NumericLiteral.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isNumericLiteral: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.BooleanLiteral)) {
      final expression = BooleanLiteral.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isBooleanLiteral: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.ListLiteral)) {
      final expression = ListLiteral.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isListLiteral: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.SetOrMapLiteral)) {
      final expression = MapLiteral.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isMapLiteral: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.MethodInvocation)) {
      final expression = MethodInvocation.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isMethodInvocation: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.MemberExpression)) {
      final expression = MemberExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isMemberExpression: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.NamedExpression)) {
      final expression = NamedExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isNamedExpression: true, ast: ast);
      }
    } else if (astType ==
        astNodeNameValue(AstNodeName.VariableDeclarationList)) {
      final expression = VariableDeclarationList.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isVariableDeclarationList: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.BinaryExpression)) {
      final expression = BinaryExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isBinaryExpression: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.AssignmentExpression)) {
      final expression = AssignmentExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isAssignmentExpression: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.PropertyAccess)) {
      final expression = PropertyAccess.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isPropertyAccess: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.ClassDeclaration)) {
      final expression = ClassDeclaration.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isClassDeclaration: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.MethodDeclaration)) {
      final expression = MethodDeclaration.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isMethodDeclaration: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.ReturnStatement)) {
      final expression = ReturnStatement.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isReturnStatement: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.FieldDeclaration)) {
      final expression = FieldDeclaration.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isFieldDeclaration: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.FunctionExpression)) {
      final expression = FunctionExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isFunctionExpression: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.BlockStatement)) {
      final expression = BlockStatement.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isBlockStatement: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.FunctionDeclaration)) {
      final expression = FunctionDeclaration.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isFunctionDeclaration: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.AwaitExpression)) {
      final expression = AwaitExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isAwaitExpression: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.PrefixExpression)) {
      final expression = PrefixExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isPrefixExpression: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.IfStatement)) {
      final expression = IfStatement.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isIfStatement: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.ForStatement)) {
      final expression = ForStatement.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isForStatement: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.SwitchStatement)) {
      final expression = SwitchStatement.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isSwitchStatement: true, ast: ast);
      }
    } else if (astType == astNodeNameValue(AstNodeName.IndexExpression)) {
      final expression = IndexExpression.fromAst(ast);
      if (expression != null) {
        return Expression(expression, isIndexExpression: true, ast: ast);
      }
    }
    return null;
  }

  Expression get asExpression => _expression as Expression;

  Identifier get asIdentifier => _expression as Identifier;

  PrefixedIdentifier get asPrefixedIdentifier =>
      _expression as PrefixedIdentifier;

  StringLiteral get asStringLiteral => _expression as StringLiteral;

  NumericLiteral get asNumericLiteral => _expression as NumericLiteral;

  BooleanLiteral get asBooleanLiteral => _expression as BooleanLiteral;

  ListLiteral get asListLiteral => _expression as ListLiteral;

  MapLiteral get asMapLiteral => _expression as MapLiteral;

  MethodInvocation get asMethodInvocation => _expression as MethodInvocation;

  MemberExpression get asMemberExpression => _expression as MemberExpression;

  NamedExpression get asNamedExpression => _expression as NamedExpression;

  VariableDeclarationList get asVariableDeclarationList =>
      _expression as VariableDeclarationList;

  BinaryExpression get asBinaryExpression => _expression as BinaryExpression;

  AssignmentExpression get asAssignmentExpression =>
      _expression as AssignmentExpression;

  PropertyAccess get asPropertyAccess => _expression as PropertyAccess;

  Program get asProgram => _expression as Program;

  ClassDeclaration get asClassDeclaration => _expression as ClassDeclaration;

  MethodDeclaration get asMethodDeclaration => _expression as MethodDeclaration;

  ReturnStatement get asReturnStatement => _expression as ReturnStatement;

  FieldDeclaration get asFieldDeclaration => _expression as FieldDeclaration;

  FunctionExpression get asFunctionExpression =>
      _expression as FunctionExpression;

  BlockStatement get asBlockStatement => _expression as BlockStatement;

  AwaitExpression get asAwaitExpression => _expression as AwaitExpression;

  PrefixExpression get asPrefixExpression => _expression as PrefixExpression;

  IfStatement get asIfStatement => _expression as IfStatement;

  ForStatement get asForStatement => _expression as ForStatement;

  SwitchStatement get asSwitchStatement => _expression as SwitchStatement;

  FunctionDeclaration get asFunctionDeclaration =>
      _expression as FunctionDeclaration;
  IndexExpression get asIndexExpression => _expression as IndexExpression;
}

class SelectAstClass {
  final String name;
  final String metadata;
  final String version;
  final String filePath;
  final String classId;

  SelectAstClass(
      {required this.name, required this.metadata, required this.version, required this.filePath, required this.classId});
  static SelectAstClass? fromAst(Map? ast) {
    if (ast != null) {
      return SelectAstClass(
          name: ast['name'],
          metadata: ast['metadata'],
          version: ast['version'],
          filePath: ast['filePath'],
          classId: ast['classId']);
    }
    return null;
  }
}

///解析ArgumentList 字段
List<Expression> _parseArgumentList(Map ast) {
  var astArguments = ast['argumentList'] as List;
  var arguments = <Expression>[];
  for (var arg in astArguments) {
    final item = Expression.fromAst(arg);
    if (item != null) {
      arguments.add(item);
    }
  }
  return arguments;
}

num _parseNumericValue(Map ast) {
  num n = 0;
  if (ast['type'] == astNodeNameValue(AstNodeName.NumericLiteral)) {
    n = ast['value'] as num;
  }
  return n;
}

String _parseStringValue(Map ast) {
  String s = "";
  if (ast['type'] == astNodeNameValue(AstNodeName.StringLiteral)) {
    s = ast['value'] as String;
  }
  return s;
}

bool _parseBooleanValue(Map ast) {
  bool b = false;
  if (ast['type'] == astNodeNameValue(AstNodeName.BooleanLiteral)) {
    b = ast['value'] as bool;
  }
  return b;
}

///解析基本数据类型
dynamic _parseLiteral(Map ast) {
  var valueType = ast['type'];
  if (valueType == astNodeNameValue(AstNodeName.StringLiteral)) {
    return _parseStringValue(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.NumericLiteral)) {
    return _parseNumericValue(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.BooleanLiteral)) {
    return _parseBooleanValue(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.SetOrMapLiteral)) {
    return MapLiteral.fromAst(ast);
  } else if (valueType == astNodeNameValue(AstNodeName.ListLiteral)) {
    return ListLiteral.fromAst(ast);
  }

  return null;
}

///解析File 对象 ast
File? parseFileObject(MethodInvocation fileMethod) {
  var callee = fileMethod.callee;
  if (callee.isIdentifier && callee.asIdentifier.name == 'File') {
    var argumentList = fileMethod.argumentList;
    if (argumentList != null &&
        argumentList.isNotEmpty &&
        argumentList[0].isStringLiteral) {
      var path = argumentList[0].asStringLiteral.value;
      return File(path);
    }
  }
  return null;
}
