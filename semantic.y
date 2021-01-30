%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  int out_lin = 0;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int lab_num = -1;
  FILE *output;

  unsigned tempType = 0; 	//pomocna promenljiva za tip promenljivih
  char* tempVar;
  int returnNum = 0;
  int paramsNum = 1; 	       //brojac parametara za funkcije sa vise parametara
  int argsNum = 1; 	      // brojac argumenata u pozivu fje
  int visePromjenljivih[20] = {0};
  int visePromjenljivihVr[20] = {NO_ATR};
  int i = 0; 
  int for_num = -1;
  int branch_num = -1;
  int forTemp = 0;
  int forNum = 1;
  int cond_num = 0; 
  int varNumSub = 0;
  int k = 0;
%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _LSBRACKET
%token _RSBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP
%token _SELECT
%token _FROM
%token _WHERE
%token _COMMA
%token _INCREMENT
%token _DECREMENT
%token _FOR
%token _BRANCH
%token _ONE
%token _TWO
%token _THREE
%token _OTHER
%token _QMARK
%token _COLON

%type <i> num_exp exp literal conditional_exp inc_it increment
%type <i> function_call argument rel_exp if_part conditional_statement

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  : global_list function_list
      {  
        if(lookup_symbol("main", FUN) == NO_INDEX)
	{
          err("Undefined reference to 'main'");
	}
       }
  ;

global_list
  : /*empty*/
  | global_list global_var
  ;

global_var
  :  _TYPE _ID _SEMICOLON
    {
	 if(lookup_symbol($2, GVAR) == NO_INDEX)
	{
           insert_symbol($2, GVAR, $1, NO_ATR, NO_ATR);
	   code("\n%s:\n\t\tWORD\t1", $2);
	}
        else
	{
           err("Redefinition of variable '%s'", $2);
	}
    }
  ;

function_list
  : function
  | function_list function
  ;

function
  : _TYPE _ID
      {
        fun_idx = lookup_symbol($2, FUN);
        if(fun_idx == NO_INDEX)
	{
          fun_idx = insert_symbol($2, FUN, $1, NO_ATR, NO_ATR);
	}
        else 
	{
          err("Redefinition of function '%s'", $2);
	}

	code("\n%s:", $2);
        code("\n\t\tPUSH\t%%14");
        code("\n\t\tMOV \t%%15,%%14");
      }
    _LPAREN parameter _RPAREN body
      {
	if(returnNum==0 && get_type(fun_idx)!=VOID)	//funkcija koja nije void tipa bi trebalo da ima povratnu vrijednost
	{
	    warning("No return statement in function!");
	}
	
        clear_symbols(fun_idx + 1);
        var_num = 0;
        returnNum=0;
        paramsNum=1;
        k = 0;

	code("\n@%s_exit:", $2);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }
  ;

parameter
  : /* no parameters*/
      { 
	set_atr1(fun_idx, 0); 
      }
  | _TYPE _ID 
      {
	if($1==VOID)
	{
	   err("Semantic error! Parameter can't be void type!");
        }
        insert_symbol($2, PAR, $1, 1, NO_ATR);
        set_atr1(fun_idx, 1);
        set_atr2(fun_idx, $1);
        set_types(fun_idx, $1, 0);  
	 
      }
    params
      {	
	//potrebno prilikom poziva funkcije, da bi se parametri u obrnutom redoslijedu push-ovali na stek
	 int j = 1;
         int i;
         for (i = get_last_element(); i > get_last_element() - paramsNum; i--) 
	 {
	    set_atr1(i,j);
	    j++;
         }
	 //print_symtab();
      }
  ;

params
  : /*only one parameter*/
  | params _COMMA _TYPE _ID
    {
	if($3==VOID)
	{
	   err("Semantic error! Parameter can't be void type!");
        }

        //int pom=$3;
        // char* s=$4;

	if(lookup_symbol($4, VAR|PAR) == NO_INDEX)
	{
           insert_symbol($4, PAR, $3, ++paramsNum, NO_ATR);
	   set_atr1(fun_idx, paramsNum);
           //set_atr2(fun_idx, $3);			//za viseparametarske funkcije je bila potrebna izmjena tabele simbola, jer atr2 predstavlja tip samo jednog parametra
   	   set_types(fun_idx, $3, paramsNum-1);		//1.parametar je 0. element niza koji predstavlja parametre u tabeli simbola i tako redom
	   //printf("\n Tip: %d, broj parametra: %d, id: %s\n", pom, paramsNum, s);
	}
        else 
	{
           err("Redefinition of '%s'", $4);
	}
    }
  ;

body
   : _LBRACKET  variable_list
      {
        if(var_num)
          code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_num);
          code("\n@%s_body:", get_name(fun_idx));

	  int j;
	//za visestruku dodjelu vrijednosti
         for(j = 0; j < var_num; j++){
	    
		if(visePromjenljivihVr[j] != NO_ATR)
			gen_mov(visePromjenljivihVr[j], visePromjenljivih[j]);
	 }
      }
     statement_list _RBRACKET
	{/*print_symtab();*/}
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : type vars assign _SEMICOLON  
  ;

type
  : _TYPE 
    {	
        if($1==VOID)
	{
	   err("Semantic error! Variable can't be void type!");
        }
	tempType = $1;	//globalna promjenljiva koja pamti tip promjenljivih (potrebno zbog smjestanja u tabelu simbola)
    }
  ;

vars
  : comma 
  | vars comma
  ;

comma
  : _ID 
     {
        if(lookup_symbol($1, VAR|PAR) == NO_INDEX)
	{
           insert_symbol($1, VAR, tempType, ++var_num, NO_ATR);
	   int idx = lookup_symbol($1, VAR|PAR);
	   visePromjenljivih[k] = idx;		//niz u kome se cuvaju indeksi u tabeli simbola
	   visePromjenljivihVr[k] = NO_ATR;    // niz u kome se cuvaju dodijeljene vrijednosti (ako promjenljiva nije inicijalizovana, dodijeljena je konstanta NO_ATR)
	   i++;				       // brojac promjenljivih u jednoj funkciji
	   k++;
	}
        else
	{
           err("Redefinition of variable '%s'", $1);
	}
	
     }
  | comma _COMMA _ID
     {
        if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
	{
           insert_symbol($3, VAR, tempType, ++var_num, NO_ATR);
	   int idx = lookup_symbol($3, VAR|PAR);
	   visePromjenljivih[k] = idx;
	   visePromjenljivihVr[k] = NO_ATR;
	   k++;
	   i++;
        }
        else 
	{
           err("Redefinition of variable '%s'", $3);
	}
     }
  ;

assign
  : /*empty*/
    {
	i = 0;
    }
  |  _ASSIGN literal
    {	
	if(tempType != get_type($2))
        {
 	   err("Incompatible types of variable and literal in assignment!");
	}  
	
          int j = 0;
	  for(j = k - 1; j >= k - i ; j--) {
		
		//gen_mov($2, visePromjenljivih[j]);  
		//visePromjenljivih[j] = $2;
		//set_atr2(visePromjenljivih[j], $2);
		visePromjenljivihVr[j] = $2;
          }
	  i = 0;
	$<i>$ = $2;
        
    }
  ;


statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | for_statement
  | branch_statement
  | return_statement
  | fcall_void_statement
  | select_statement
  | increment_statement
  | decrement_statement
  ;

compound_statement
  : _LBRACKET statement_list _RBRACKET
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR|GVAR);
        if(idx == NO_INDEX)
	{
          err("Invalid lvalue '%s' in assignment", $1);
	}
        else
	{
            if(get_type(idx) != get_type($3))
	    {
	     //printf("\n TIP1: %u \n", get_type(idx));
	     //printf("\n TIP2: %u \n", get_type($3));
	     //printf("\n TIP2: %u \n", literalType);
              err("Incompatible types in assignment");
	    } 
	    gen_mov($3, idx);
	}   
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
	{
          err("Invalid operands: arithmetic operation");
	}
	 int t1 = get_type($1);    
        code("\n\t\t%s\t", ar_instructions[$2 + (t1 - 1) * AROP_NUMBER]);
        gen_sym_name($1);
        code(",");
        gen_sym_name($3);
        code(",");
        free_if_reg($3);
        free_if_reg($1);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);

	if(get_atr2($1) == 5)	//potrebno za postinkrement u izrazu (ideja je da se svakoj inkrementovanoj promjenljivoj set-uje atr2 na proizvoljnu konstantu, npr. 5)
	{
		int t1 = get_type($1);

		if(get_kind($1) == VAR || get_kind($1) == PAR)
		{	
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);		//ADDS
		     else
			code("\n\t\t%s\t", ar_instructions[4]);   	//ADDU

		     gen_sym_name($1);
		 
		     code(",$1,");

		     gen_sym_name($1);
		
		     set_atr2($1, 0);					//nakon inkrementovanja, resetuje se vrijednost atr2 da se ne bi opet inkrementovala promjenljiva
		}
	
		if(get_kind($1) == GVAR)
		{
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);  

		     code("%s,$1,%s", get_name($1), get_name($1)); 
		
		       set_atr2($1, 0);
		}
	}

	
	if(get_atr2($3) == 5)
	{
		int t1 = get_type($3);

		if(get_kind($3) == VAR || get_kind($3) == PAR)
		{	
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);   

		     gen_sym_name($3);
		 
		     code(",$1,");

		     gen_sym_name($3);
		}
	
		if(get_kind($3) == GVAR)
		{
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);  

		     code("%s,$1,%s", get_name($3), get_name($3)); 
		}
		set_atr2($3, 0);
	}
      }
  ;

exp
  : literal
  | _ID 
      {
        $$ = lookup_symbol($1, VAR|PAR|GVAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
  | increment
      {
	$$ = $1;
      }
  | function_call
      {
        $$ = take_reg();
        gen_mov(FUN_REG, $$);
      }
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
  | conditional_exp
  ;

increment
  : _ID _INCREMENT
    {
	int idx=lookup_symbol($1, VAR|PAR|GVAR);
	
	if(idx == NO_INDEX)
	  err("'%s' undeclared", $1);
      
	if(get_kind(idx)!=VAR && get_kind(idx)!=PAR && get_kind(idx)!=GVAR)
	{
	  err("Semantic error! The postincrement operator can only be used with variables and parameters!");
	}

	int t1 = get_type(idx);

	set_atr2(idx, 5);

	$$ = idx;
    }
  ;


literal
  : _INT_NUMBER
      { 
	$$ = insert_literal($1, INT); 
      }

  | _UINT_NUMBER
      { 
	$$ = insert_literal($1, UINT);
      }
  ;

conditional_exp
  : _LPAREN  rel_exp 
    {
	code("\n\t\t%s\t@false_cond%d", opp_jumps[$2], cond_num);
	code("\n@true_cond%d:", cond_num);
    }
    _RPAREN  _QMARK conditional_statement

    _COLON conditional_statement
      {
	 if(get_type($6) != get_type($8))
	    err("Incompatible types of expressions in conditional expression!");
	// $<i>$ = $9;
	// gen_sym_name($9);
	 int reg = take_reg();

 	 gen_mov($6, reg);
	 code("\n\t\tJMP \t@exit_cond%d", cond_num);

	 code("\n@false_cond%d:", cond_num);
	 gen_mov($8, reg);
	

	 set_type(reg, get_type($6));
	 $$ = reg;

	 code("\n@exit_cond%d:", cond_num);

         var_num++;
      } 
  ;

conditional_statement
  : _ID
    { 
	int idx = lookup_symbol($1, VAR|PAR|GVAR);
	if(idx == NO_INDEX)
	    err("Undefined variable/parameter '%s'!", get_name(idx));
        $<i>$ = idx;
    }
  | literal
  ;


function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
      }
    _LPAREN argument _RPAREN
      {
        if(get_atr1(fcall_idx) != $4)
          err("Wrong number of args to function '%s'", get_name(fcall_idx));

	code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);

        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;
        argsNum = 1;			 //posle poziva fje resetujemo brojac argumenata na 1
      }
  ;


fcall_void_statement			//poziv void fje
  : _ID 
     { 
	fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
     }
   _LPAREN argument _RPAREN _SEMICOLON
     {
	 if(get_atr1(fcall_idx) != $4)
          err("Wrong number of args to function '%s'", get_name(fcall_idx));

	code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);

        argsNum = 1;			
     }
  ;

argument
  : /* empty */
    { $$ = 0; }

  | num_exp 				//ima bar 1 argument
    { 
      if(get_atr2(fcall_idx) != get_type($1))
        err("Incompatible type for argument in '%s'", get_name(fcall_idx));
	
      free_if_reg($1);
      code("\n\t\t\tPUSH\t");
      gen_sym_name($1);
      $<i>$ = 1;
    }

    args
    {
       $$ = argsNum;
    }
  ;

args
  : /*samo 1 argument*/
  | args _COMMA num_exp 	       //vise od 1 argumenta
    {
       argsNum++;

       if(get_types(fcall_idx, argsNum-1) != get_type($3))
          err("Incompatible type for argument in '%s'", get_name(fcall_idx));

      free_if_reg($3);
      code("\n\t\t\tPUSH\t");
      gen_sym_name($3);
      $<i>$ = argsNum;
    }
  ;

if_statement
  : if_part %prec ONLY_IF
      { 
	code("\n@exit_if%d:", $1); 
	//lab_num = -1;
      }
  | if_part _ELSE statement
      { 
	code("\n@exit_if%d:", $1); 
       // lab_num = -1;
      }
  ;

if_part
  : _IF _LPAREN 
      {
        $<i>$ = ++lab_num;
        code("\n@if%d:", lab_num);
      }
     rel_exp 
      {
        code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3);
        code("\n@true%d:", $<i>3);
      }
    _RPAREN statement
      {
        code("\n\t\tJMP \t@exit_if%d", $<i>3);
        code("\n@false%d:", $<i>3);
        $$ = $<i>3;
      }
  ;

rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
           err("Invalid operands: relational operator");
	$$ = $2 + ((get_type($1) - 1) * RELOP_NUMBER);

  	if(get_atr2($1) == 5)
	{
		int t1 = get_type($1);

		if(get_kind($1) == VAR || get_kind($1) == PAR)
		{	
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);   

		     gen_sym_name($1);
		 
		     code(",$1,");

		     gen_sym_name($1);
		
		     set_atr2($1, 0);
		}
	
		if(get_kind($1) == GVAR)
		{
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);  

		     code("%s,$1,%s", get_name($1), get_name($1)); 
		
		       set_atr2($1, 0);
		}
	}

	
	if(get_atr2($3) == 5)
	{
		int t1 = get_type($3);

		if(get_kind($3) == VAR || get_kind($3) == PAR)
		{	
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);   

		     gen_sym_name($3);
		 
		     code(",$1,");

		     gen_sym_name($3);
		}
	
		if(get_kind($3) == GVAR)
		{
		     if(t1 == 1)
		     	code("\n\t\t%s\t", ar_instructions[0]);
		     else
			code("\n\t\t%s\t", ar_instructions[4]);  

		     code("%s,$1,%s", get_name($3), get_name($3)); 
		}
		set_atr2($3, 0);
	}	

        gen_cmp($1, $3);
      }
  ;

for_statement
  : _FOR _LPAREN _TYPE _ID _ASSIGN literal _SEMICOLON 
      {
	  if(lookup_symbol($4, VAR|PAR) == NO_INDEX)
	  {
             insert_symbol($4, VAR, $3, ++var_num, NO_ATR);
	  }
          else 
	  {
              err("Redefinition of variable '%s'", $4);
	  }
		
	  int var = lookup_symbol($4, VAR);
	  if(get_type(var) != get_type($6))
	  {
	     err("Incompatible types in assignment!");
	  }	
	  
	
	  code("\n\t\tSUBS\t%%15,$%d,%%15", 4);
	// forTemp++;
	
          gen_mov($6, var);

         $<i>$ = ++for_num;
         code("\n@for%d:", for_num);
	 //gen_mov($6, var);
      }
      
     rel_exp 
      {
	code("\n\t\t%s\t@exit_for%d", opp_jumps[$9], $<i>8);
      }
    _SEMICOLON inc_it _RPAREN statement 
      {	
        int t1 = get_type($12);

	if(get_kind($12) == VAR || get_kind($12) == PAR)
	{

	     if(t1 == 1)
	     	code("\n\t\t%s\t", ar_instructions[0]);
	     else
	        code("\n\t\t%s\t", ar_instructions[4]);   

	     gen_sym_name($12);
	 
	     code(",$1,");

	     gen_sym_name($12);
	}
	
	/*if(get_kind($12) == GVAR)
	{
	     if(t1 == 1)
	     	code("\n\t\t%s\t", ar_instructions[0]);
	     else
	        code("\n\t\t%s\t", ar_instructions[4]);  

	     code("%s,$1,%s", get_name($12), get_name($12)); 
	}*/
	code("\n\t\tJMP \t@for%d", $<i>8);
	code("\n@exit_for%d:", $<i>8);
       // for_num = -1;
      }
  ;

inc_it
  :  _ID  _INCREMENT
      {	
	int idx=lookup_symbol($1, VAR|PAR);
	if(idx == NO_INDEX)
	    err("'%s' undeclared", $1);
      
	if(get_kind(idx)!=VAR && get_kind(idx)!=PAR)
	{
	  err("Semantic error! The postincrement operator can only be used with variables and parameters!");
	}

	$$ = idx;
     }
  ;


branch_statement
  : _BRANCH _LSBRACKET _ID 

     {
	  if(lookup_symbol($3, VAR|PAR|GVAR) == NO_INDEX)
	  {
             err("'%s' undeclared", $3);
	  }
	  $<i>$ = ++branch_num;
          code("\n@branch%d:", branch_num);
      }

    _SEMICOLON literal 
	{
	   int var = lookup_symbol($3, VAR|PAR|GVAR);
	   if(get_type(var)!=get_type($6))
	   {
              err("Incompatible types of var and literal!");
	   } 

	  if(get_type(var) == INT)
	    code("\n\t\tCMPS \t");
	  else
	    code("\n\t\tCMPU \t");
	  gen_sym_name(var);
	  code(",");
	  gen_sym_name($6);

	   code("\n\t\tJEQ\t@one%d", branch_num);
	   
	}
    _COMMA literal 
	{
	   int var = lookup_symbol($3, VAR|PAR|GVAR);
	   if(get_type(var)!=get_type($9))
	   {
              err("Incompatible types of var and literal!");
	   } 

	  if(get_type(var) == INT)
	    code("\n\t\tCMPS \t");
	  else
	    code("\n\t\tCMPU \t");
	  gen_sym_name(var);
	  code(",");
	  gen_sym_name($9);

	   code("\n\t\tJEQ\t@two%d", branch_num);
	   
	}
    _COMMA literal

	{
	   int var = lookup_symbol($3, VAR|PAR|GVAR);
	   if(get_type(var)!=get_type($12))
	   {
              err("Incompatible types of var and literal!");
	   } 

	   if(get_type(var) == INT)
	    code("\n\t\tCMPS \t");
	   else
	    code("\n\t\tCMPU \t");
	   gen_sym_name(var);
	   code(",");
	   gen_sym_name($12);	

	   code("\n\t\tJEQ\t@three%d", branch_num);
	   code("\n\t\tJMP\t@other%d", branch_num);
	  
	}
    _RSBRACKET
	{
	   code("\n@one%d:", branch_num);
	}
    _ONE statement 
        {
	   code("\n\t\tJMP\t@exit%d", $<i>4);
	   code("\n@two%d:", branch_num);
	}
    _TWO statement 
	{
	   code("\n\t\tJMP\t@exit%d", $<i>4);
	   code("\n@three%d:", branch_num);
	}
    _THREE statement 
	{
	   code("\n\t\tJMP\t@exit%d", $<i>4);
	   code("\n@other%d:", branch_num);
	}
    _OTHER statement
	{
	  code("\n@exit%d:", $<i>4);
	}
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
      {
	returnNum++;
        if(get_type(fun_idx) != get_type($2))
	{
          err("Incompatible types in return");
	}
	
	gen_mov($2, FUN_REG);
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx)); 

	if(get_type(fun_idx) == VOID)
	{
	  err("Semantic error! Void function can't return a value!");
	}
      }

  | _RETURN _SEMICOLON
      {
	returnNum++;

	if(get_type(fun_idx)!=VOID)
	{
           warning("Non-void function must return a value!");
	}
      }
  ;

increment_statement
  : _ID _INCREMENT _SEMICOLON
     {	
	int idx=lookup_symbol($1, VAR|PAR|GVAR);
      
	if(get_kind(idx)!=VAR && get_kind(idx)!=PAR && get_kind(idx)!=GVAR)
	{
	  err("Semantic error! The postincrement operator can only be used with variables and parameters!");
	}

	int t1 = get_type(idx);

	if(get_kind(idx) == VAR || get_kind(idx) == PAR)
	{	
	     if(t1 == 1)
	     	code("\n\t\t%s\t", ar_instructions[0]);
	     else
	        code("\n\t\t%s\t", ar_instructions[4]);   

	     gen_sym_name(idx);
	 
	     code(",$1,");

	     gen_sym_name(idx);
	}
	
	if(get_kind(idx) == GVAR)
	{
	     if(t1 == 1)
	     	code("\n\t\t%s\t", ar_instructions[0]);
	     else
	        code("\n\t\t%s\t", ar_instructions[4]);  

	     code("%s,$1,%s", $1, $1); 
	}
     }
  ;

decrement_statement
  : _ID _DECREMENT _SEMICOLON
    {
	int idx=lookup_symbol($1, VAR|PAR|GVAR);
      
	if(get_kind(idx)!=VAR && get_kind(idx)!=PAR && get_kind(idx)!=GVAR)
	{
	  err("Semantic error! The postdecrement operator can only be used with variables and parameters!");
	}

	int t1 = get_type(idx);

	if(get_kind(idx) == VAR || get_kind(idx) == PAR)
	{	
	     if(t1 == 1)
	     	code("\n\t\t%s\t", ar_instructions[1]);
	     else
	        code("\n\t\t%s\t", ar_instructions[5]);   

	     gen_sym_name(idx);
	 
	     code(",$1,");

	     gen_sym_name(idx);
	}
	
	if(get_kind(idx) == GVAR)
	{
	     if(t1 == 1)
	     	code("\n\t\t%s\t", ar_instructions[1]);
	     else
	        code("\n\t\t%s\t", ar_instructions[5]);  

	     code("%s,$1,%s", $1, $1); 
	}
    }
  ;

select_statement
  : _SELECT vars _FROM _ID _WHERE _LPAREN rel_exp _RPAREN _SEMICOLON
  ;

%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

int main() {
  int synerr;
  init_symtab();
  output = fopen("output.asm", "w+");

  synerr = yyparse();
  //print_symtab();
  clear_symtab();
  fclose(output);
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count) {
    remove("output.asm");
    printf("\n%d error(s).\n", error_count);
  }

  if(synerr)
    return -1;  //syntax error
  else if(error_count)
    return error_count & 127; //semantic errors
  else if(warning_count)
    return (warning_count & 127) + 127; //warnings
  else
    return 0; //OK
}

