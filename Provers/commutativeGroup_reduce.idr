-- Edwin Brady, Franck Slama
-- University of St Andrews
-- File commutativeGroup_reduce.idr
-- Normalize an expression reflecting an element in a commutative group
-------------------------------------------------------------------

module Provers.commutativeGroup_reduce

import Decidable.Equality
import Data.Vect
import Data.Fin
import Provers.dataTypes
import Provers.tools
import Provers.group_reduce

-- Order : Variable (in order) and then constants


-- Finally not needed

assoc_and_commute : {c:Type} -> {p:CommutativeGroup c} -> (x : c) -> (y : c) -> (z : c) -> (Plus (Plus x y) z ~= Plus (Plus y z) x)
assoc_and_commute x y z = let aux : (Plus (Plus x y) z ~= Plus x (Plus y z)) = Plus_assoc x y z in
								?Massoc_and_commute_1


-- A usufel lemma for most rewriting in this section
assoc_commute_and_assoc : {c:Type} -> {p:CommutativeGroup c} -> (x : c) -> (y : c) -> (z : c) -> (Plus (Plus x y) z ~= Plus (Plus x z) y)
assoc_commute_and_assoc {c} x y z = let aux : (Plus (Plus x y) z ~= Plus x (Plus y z)) = Plus_assoc {c} x y z in
								let aux2 : (Plus x (Plus y z) ~= Plus x (Plus z y)) = ?Massoc_commute_and_assoc_1 in
								let aux3 : (Plus x (Plus z y) ~= Plus (Plus x z) y) = (set_eq_undec_sym {c} (Plus_assoc x z y)) in
									?Massoc_commute_and_assoc_2

									
assoc_and_neutral : {c:Type} -> {p:dataTypes.Group c} -> (x : c) -> (y : c) -> (Plus x (Plus (Neg x) y) ~= y)
assoc_and_neutral {c} x y = let aux : (Plus x (Plus (Neg x) y) ~= Plus (Plus x (Neg x)) y) = (set_eq_undec_sym {c} (Plus_assoc {c} x (Neg x) y)) in
						let aux2 : (Plus x (Neg x) ~= Zero) = left (Plus_inverse x) in
						let aux3 : (Plus Zero y ~= y) = Plus_neutral_1 y in
							?Massoc_and_neutral_1

assoc_and_neutral_bis : {c:Type} -> {p:dataTypes.Group c} -> (x : c) -> (y : c) -> (Plus (Neg x) (Plus x y) ~= y)
assoc_and_neutral_bis {c} x y = let aux : (Plus (Neg x) (Plus x y) ~= Plus (Plus (Neg x) x) y) = (set_eq_undec_sym {c} (Plus_assoc {c} (Neg x) x y)) in
							let aux2 : (Plus (Neg x) x ~= Zero) = right (Plus_inverse {c} x) in
							let aux3 : (Plus Zero y ~= y) = Plus_neutral_1 y in
							?Massoc_and_neutral_bis_1
							
									
-- 4 FUNCTIONS WHICH ADD A TERM TO AN EXPRESSION ALREADY "SORTED" (of the right forme)
-- -----------------------------------------------------------------------------------
-- The expression is already in the form a + (b + (c + ...)) where a,b,c can only be constants, variables, and negations of constants and variables
putVarOnPlace : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} 
	-> (ExprCG p setAndMult g c1) -> {varValue:c} 
	-> (Variable (commutativeGroup_to_set p) Neg setAndMult g varValue) 
	-> (c2 ** (ExprCG p setAndMult g c2, Plus c1 varValue~=c2))
putVarOnPlace p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e) (RealVariable _ _ _ _ i) = 
    if minusOrEqual_Fin i0 i 
		then let (r_ihn ** (e_ihn, p_ihn)) = (putVarOnPlace p setAndMult e (RealVariable _ _ _ _ i)) in
             (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e_ihn, ?MputVarOnPlace_1))
        else (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e), ?MputVarOnPlace_2))
putVarOnPlace p setAndMult (PlusCG _ (ConstCG _ _ _ c0) e) (RealVariable _ _ _ _ i) = 
	(_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (PlusCG _ (ConstCG _ _ _ c0) e), ?MputVarOnPlace_3)) -- the variable becomes the first one, and e is already sorted, there's no need to do a recursive call here !        
putVarOnPlace p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e) (RealVariable _ _ _ _ i) = 
	 if minusOrEqual_Fin i0 i 
		then let (r_ihn ** (e_ihn, p_ihn)) = (putVarOnPlace p setAndMult e (RealVariable _ _ _ _ i)) in
			 (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e_ihn, ?MputVarOnPlace_4))
		else (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e), ?MputVarOnPlace_5))
putVarOnPlace p setAndMult (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e) (RealVariable _ _ _ _ i) = 
	(_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e), ?MputVarOnPlace_6)) -- the variable becomes the first one, and e is already sorted, there's no need to do a recursive call here !
-- Basic cases : cases without Plus
putVarOnPlace p setAndMult (ConstCG _ _ _ c0) (RealVariable _ _ _ _ i) = (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (ConstCG _ _ _ c0), ?MputVarOnPlace_7))
putVarOnPlace p setAndMult (NegCG _ (ConstCG _ _ _ c0)) (RealVariable _ _ _ _ i) = (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (ConstCG _ _ _ (Neg c0)), ?MputVarOnPlace_8))
putVarOnPlace {c} p setAndMult (VarCG p _ (RealVariable _ _ _ _ i0)) (RealVariable _ _ _ _ i) = 
	    if minusOrEqual_Fin i0 i then (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (VarCG p _ (RealVariable _ _ _ _ i)), set_eq_undec_refl {c} _))
		else (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (VarCG p _ (RealVariable _ _ _ _ i0)), ?MputVarOnPlace_9))
putVarOnPlace {c} p setAndMult (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (RealVariable _ _ _ _ i) = 
		if minusOrEqual_Fin i0 i then (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (VarCG p _ (RealVariable _ _ _ _ i)), set_eq_undec_refl {c} _))
		else (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i)) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))), ?MputVarOnPlace_10))

	

putConstantOnPlace : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} 
   -> (ExprCG p setAndMult g c1) -> (constValue:c) 
   -> (c2 ** (ExprCG p setAndMult g c2, Plus c1 constValue~=c2))
putConstantOnPlace p setAndMult (PlusCG _ (ConstCG _ _ _ c0) e) constValue = (_ ** (PlusCG _ (ConstCG _ _ _ (Plus c0 constValue)) e, ?MputConstantOnPlace_1))
putConstantOnPlace p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e) constValue = 
	let (r_ihn ** (e_ihn, p_ihn)) = putConstantOnPlace p setAndMult e constValue in
		(_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e_ihn, ?MputConstantOnPlace_2))
putConstantOnPlace p setAndMult (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e) constValue = (_ ** (PlusCG _ (ConstCG _ _ _ (Plus (Neg c0) constValue)) e, ?MputConstantOnPlace_3)) -- Perhaps useless because I think that NegCG _ (ConstCG _ c) is always ConstCG _ (Neg c) at this stage
putConstantOnPlace p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e) constValue = 
	let (r_ihn ** (e_ihn, p_ihn)) = putConstantOnPlace p setAndMult e constValue in
		(_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e_ihn, ?MputConstantOnPlace_4))
-- Basic cases : cases without Plus
putConstantOnPlace {c} p setAndMult (ConstCG _ _ _ c0) constValue = (_ ** (ConstCG _ _ _ (Plus c0 constValue), set_eq_undec_refl {c} _))
putConstantOnPlace {c} p setAndMult (NegCG _ (ConstCG _ _ _ c0)) constValue = (_ ** (ConstCG _ _ _ (Plus (Neg c0) constValue), set_eq_undec_refl {c} _))
putConstantOnPlace {c} p setAndMult (VarCG p _ (RealVariable _ _ _ _ i0)) constValue = (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (ConstCG _ _ _ constValue), set_eq_undec_refl {c} _))
putConstantOnPlace {c} p setAndMult (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) constValue = (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (ConstCG _ _ _ constValue), set_eq_undec_refl {c} _))



putNegVarOnPlace : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} 
   -> (ExprCG p setAndMult g c1) -> {varValue:c} 
   -> (Variable (commutativeGroup_to_set p) Neg setAndMult g varValue) 
   -> (c2 ** (ExprCG p setAndMult g c2, Plus c1 (Neg varValue)~=c2))
putNegVarOnPlace p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e) (RealVariable _ _ _ _ i) = 
    if minusOrEqual_Fin i0 i 
	then let (r_ihn ** (e_ihn, p_ihn)) = (putNegVarOnPlace p setAndMult e (RealVariable _ _ _ _ i)) in
             (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e_ihn, ?MputNegVarOnPlace_1))
		else (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e), ?MputNegVarOnPlace_2))
putNegVarOnPlace p setAndMult (PlusCG _ (ConstCG _ _ _ c0) e) (RealVariable _ _ _ _ i) = 
	(_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (PlusCG _ (ConstCG _ _ _ c0) e), ?MputNegVarOnPlace_3)) -- the negation of the variable becomes the first one, and e is already sorted, there's no need to do a recursive call here !
        
putNegVarOnPlace p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e) (RealVariable _ _ _ _ i) =
	 if minusOrEqual_Fin i0 i 
	 then let (r_ihn ** (e_ihn, p_ihn)) = (putNegVarOnPlace p setAndMult e (RealVariable _ _ _ _ i)) in
			 (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e_ihn, ?MputNegVarOnPlace_4))
		else (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e), ?MputNegVarOnPlace_5))
putNegVarOnPlace p setAndMult (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e) (RealVariable _ _ _ _ i) = 
	(_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e), ?MputNegVarOnPlace_6)) -- the negation of the variable becomes the first one, and e is already sorted, there's no need to do a recursive call here !
-- Basic cases : cases without Plus
putNegVarOnPlace p setAndMult (ConstCG _ _ _ c0) (RealVariable _ _ _ _ i) = (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (ConstCG _ _ _ c0), ?MputNegVarOnPlace_7))
putNegVarOnPlace p setAndMult (NegCG _ (ConstCG _ _ _ c0)) (RealVariable _ _ _ _ i) = (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (ConstCG _ _ _ (Neg c0)), ?MputNegVarOnPlace_8))
putNegVarOnPlace {c} p setAndMult (VarCG p _ (RealVariable _ _ _ _ i0)) (RealVariable _ _ _ _ i) = 
	    if minusOrEqual_Fin i0 i then (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))), set_eq_undec_refl {c} _))
		else (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (VarCG p _ (RealVariable _ _ _ _ i0)), ?MputNegVarOnPlace_9))
putNegVarOnPlace {c} p setAndMult (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (RealVariable _ _ _ _ i) = 
		if minusOrEqual_Fin i0 i then (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))), set_eq_undec_refl {c} _))
		else (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i))) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))), ?MputNegVarOnPlace_10))


putNegConstantOnPlace : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} 
   -> (ExprCG p setAndMult g c1) -> (constValue:c) 
   -> (c2 ** (ExprCG p setAndMult g c2, Plus c1 (Neg constValue)~=c2))
putNegConstantOnPlace p setAndMult (PlusCG _ (ConstCG _ _ _ c0) e) constValue = (_ ** (PlusCG _ (ConstCG _ _ _ (Plus c0 (Neg constValue))) e, ?MputNegConstantOnPlace_1))
putNegConstantOnPlace p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e) constValue = 
	let (r_ihn ** (e_ihn, p_ihn)) = putNegConstantOnPlace p setAndMult e constValue in
		(_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e_ihn, ?MputNegConstantOnPlace_2))
putNegConstantOnPlace p setAndMult (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e) constValue = (_ ** (PlusCG _ (ConstCG _ _ _ (Plus (Neg c0) (Neg constValue))) e, ?MputNegConstantOnPlace_3)) -- Perhaps useless because I think that NegCG _ (ConstCG _ c) is always ConstCG _ (Neg c) at this stage
putNegConstantOnPlace p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e) constValue = 
	let (r_ihn ** (e_ihn, p_ihn)) = putNegConstantOnPlace p setAndMult e constValue in
		(_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e_ihn, ?MputNegConstantOnPlace_4))
-- Basic cases : cases without Plus
putNegConstantOnPlace {c} p setAndMult (ConstCG _ _ _ c0) constValue = (_ ** (ConstCG _ _ _ (Plus c0 (Neg constValue)), set_eq_undec_refl {c} _))
putNegConstantOnPlace {c} p setAndMult (NegCG _ (ConstCG _ _ _ c0)) constValue = (_ ** (ConstCG _ _ _ (Plus (Neg c0) (Neg constValue)), set_eq_undec_refl {c} _))
putNegConstantOnPlace {c} p setAndMult (VarCG p _ (RealVariable _ _ _ _ i0)) constValue = (_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (ConstCG _ _ _ (Neg constValue)), set_eq_undec_refl {c} _))
putNegConstantOnPlace {c} p setAndMult (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) constValue = (_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (ConstCG _ _ _ (Neg constValue)), set_eq_undec_refl {c} _))
		
		

-- FUNCTION WHICH REORGANIZE AN EXPRESSION	
-- -----------------------------------------

-- The general pattern is reorganize (Plus term exp) = putTermOnPlace (reorganize exp) term
reorganize : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} -> (ExprCG p setAndMult g c1) -> (c2 ** (ExprCG p setAndMult g c2, c1~=c2))
reorganize p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e) = 
	let (r_ihn ** (e_ihn, p_ihn)) = reorganize p setAndMult e in
	let (r_add ** (e_add, p_add)) = putVarOnPlace p setAndMult e_ihn (RealVariable _ _ _ _ i0) in
		(_ ** (e_add, ?Mreorganize_1))
reorganize p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e) = 
	let (r_ihn ** (e_ihn, p_ihn)) = reorganize p setAndMult e in
	let (r_add ** (e_add, p_add)) = putNegVarOnPlace p setAndMult e_ihn (RealVariable _ _ _ _ i0) in
		(_ ** (e_add, ?Mreorganize_2))	
reorganize p setAndMult (PlusCG _ (ConstCG _ _ _ c0) e) = 
	let (r_ihn ** (e_ihn, p_ihn)) = reorganize p setAndMult e in
	let (r_add ** (e_add, p_add)) = putConstantOnPlace p setAndMult e_ihn c0 in
		(_ ** (e_add, ?Mreorganize_3))	
reorganize p setAndMult (PlusCG _ (NegCG _ (ConstCG _ _ _ c0)) e) = 
	let (r_ihn ** (e_ihn, p_ihn)) = reorganize p setAndMult e in
	let (r_add ** (e_add, p_add)) = putNegConstantOnPlace p setAndMult e_ihn c0 in
		(_ ** (e_add, ?Mreorganize_4))	
reorganize p setAndMult {c} e = (_ ** (e, set_eq_undec_refl {c} _))


-- SIMPLIFY BY DELETING TERMS AND THEIR SYMMETRICS	
-- ------------------------------------------------

simplifyAfterReorg : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} -> (ExprCG p setAndMult g c1) -> (c2 ** (ExprCG p setAndMult g c2, c1~=c2))
-- var + (-var + e)
simplifyAfterReorg p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i1))) e)) with (eq_dec_fin i0 i1)
	simplifyAfterReorg p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e)) | (Just Refl) = 
		let (r_ihn ** (e_ihn, p_ihn)) = simplifyAfterReorg p setAndMult e in
			(_ ** (e_ihn, ?MsimplifyAfterReorg_1))
	simplifyAfterReorg p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i1))) e)) | (Nothing) = 
		let (r_ihn ** (e_ihn, p_ihn)) = simplifyAfterReorg p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i1))) e) in
			(_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e_ihn, ?MsimplifyAfterReorg_2))

-- (-var) + (var + e)
simplifyAfterReorg p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i1)) e)) with (eq_dec_fin i0 i1)
	simplifyAfterReorg p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) e)) | (Just Refl) = 
		let (r_ihn ** (e_ihn, p_ihn)) = simplifyAfterReorg p setAndMult e in
			(_ ** (e_ihn, ?MsimplifyAfterReorg_3))
	simplifyAfterReorg p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i1)) e)) | (Nothing) = 	
		let (r_ihn ** (e_ihn, p_ihn)) = simplifyAfterReorg p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i1)) e) in
			(_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) e_ihn, ?MsimplifyAfterReorg_4)) 
	
-- Any other case with the first two elements not simplifiable
-- something + (somethingElse + e)
simplifyAfterReorg p setAndMult (PlusCG _ t1 (PlusCG _ t2 exp)) = 
	let (r_ihn ** (e_ihn, p_ihn)) = simplifyAfterReorg p setAndMult (PlusCG _ t2 exp) in
		(_ ** (PlusCG _ t1 e_ihn, ?MsimplifyAfterReorg_5))

-- Just a plus with two terms
simplifyAfterReorg {c} p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i1)))) with (eq_dec_fin i0 i1)
	simplifyAfterReorg {c} p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0)))) | (Just Refl) =
		(_ ** (ConstCG _ _ _ Zero, ?MsimplifyAfterReorg_6))
	simplifyAfterReorg {c} p setAndMult (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i1)))) | (Nothing) =
		(_ ** (PlusCG _ (VarCG p _ (RealVariable _ _ _ _ i0)) (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i1))), set_eq_undec_refl {c} _))
		
simplifyAfterReorg {c} p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (VarCG p _ (RealVariable _ _ _ _ i1))) with (eq_dec_fin i0 i1)
	simplifyAfterReorg {c} p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (VarCG p _ (RealVariable _ _ _ _ i0))) | (Just Refl) =
		(_ ** (ConstCG _ _ _ Zero, ?MsimplifyAfterReorg_7))
	simplifyAfterReorg {c} p setAndMult (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (VarCG p _ (RealVariable _ _ _ _ i1))) | (Nothing) =
		(_ ** (PlusCG _ (NegCG _ (VarCG p _ (RealVariable _ _ _ _ i0))) (VarCG p _ (RealVariable _ _ _ _ i1)), set_eq_undec_refl {c} _))
		
--Anything else simply gives the same value
simplifyAfterReorg {c} p setAndMult e = (_ ** (e, set_eq_undec_refl {c} _)) 



simplifyAfterReorg_fix : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} -> (ExprCG p setAndMult g c1) -> (c2 ** (ExprCG p setAndMult g c2, c1~=c2))
simplifyAfterReorg_fix p setAndMult e = 
	let (r_1 ** (e_1, p_1)) = simplifyAfterReorg p setAndMult e in
		case exprCG_eq p _ _ e e_1 of -- Look for syntactical equality (ie, if we have done some simplification in the last passe)!
			Just pr => (r_1 ** (e_1, p_1)) -- Previous and current term are the same : we stop here
			Nothing => let (r_ih1 ** (e_ih1, p_ih1)) = simplifyAfterReorg_fix p setAndMult e_1 in -- We do another passe
							(r_ih1 ** (e_ih1, ?MsimplifyAfterReorg_fix_1))


--WHY DO WE NEED THIS IN THE FUNCTION elimZeroCG JUST UNDER ? THAT'S CRAP !
getZero : {c:Type} -> (p:dataTypes.CommutativeGroup c) -> c
getZero p = Zero


elimZeroCG : {c:Type} -> (p:CommutativeGroup c) -> (setAndMult:SetWithMult c (commutativeGroup_to_set p)) -> {g:Vect n c} -> {c1:c} -> (ExprCG p setAndMult g c1) -> (c2 ** (ExprCG p setAndMult g c2, c1~=c2))
elimZeroCG {c} p setAndMult (ConstCG p _ _ const) = (_ ** (ConstCG p _ _ const, set_eq_undec_refl {c} _))
elimZeroCG {c} p setAndMult (PlusCG _ (ConstCG p _ _ const1) (VarCG p _ v)) with (commutativeGroup_eq_as_elem_of_set p Zero const1)
    elimZeroCG {c} p setAndMult (PlusCG _ (ConstCG p _ _ const1) (VarCG p _ v)) | (Just const1_eq_zero) = (_ ** (VarCG p _ v, ?MelimZeroCG1))
    elimZeroCG {c} p setAndMult (PlusCG _ (ConstCG p _ _ const1) (VarCG p _ v)) | _ = (_ ** (PlusCG _ (ConstCG p _ _ const1) (VarCG p _ v), set_eq_undec_refl {c} _))
elimZeroCG {c} p setAndMult (PlusCG _ (VarCG _ _ v) (ConstCG _ _ _ const2)) with (commutativeGroup_eq_as_elem_of_set p Zero const2) 
    elimZeroCG {c} p setAndMult (PlusCG _ (VarCG _ _ v) (ConstCG _ _ _ const2)) | (Just const2_eq_zero) = (_ ** (VarCG _ _ v, ?MelimZeroCG2))
    elimZeroCG {c} p setAndMult (PlusCG _ (VarCG _ _ v) (ConstCG _ _ _ const2)) | _ = (_ ** (PlusCG _ (VarCG _ _ v) (ConstCG _ _ _ const2), set_eq_undec_refl {c} _))
elimZeroCG p setAndMult (PlusCG _ e1 e2) = 
	let (r_ih1 ** (e_ih1, p_ih1)) = (elimZeroCG p setAndMult e1) in
	let (r_ih2 ** (e_ih2, p_ih2)) = (elimZeroCG p setAndMult e2) in
        ((Plus r_ih1 r_ih2) ** (PlusCG _ e_ih1 e_ih2, ?MelimZeroCG3))
elimZeroCG {c} p setAndMult (VarCG _ _ v) = (_ ** (VarCG _ _ v, set_eq_undec_refl {c} _))
-- No treatment for Minus since they have already been simplified
-- and no treatment for Neg since we should not find a constant inside a Neg at this point
elimZeroCG {c} p setAndMult e = (_ ** (e, set_eq_undec_refl {c} _))



commutativeGroupReduce : (p:CommutativeGroup c) -> {setAndMult:SetWithMult c (commutativeGroup_to_set p)} -> {g:Vect n c} -> {c1:c} -> (ExprCG p setAndMult g c1) -> (c2 ** (ExprCG p setAndMult g c2, c1~=c2))
commutativeGroupReduce p e =
    let e_1 = commutativeGroup_to_group e in
    let (r_2 ** (e_2, p_2)) = groupReduce _ e_1 in
    let e_3 = group_to_commutativeGroup p e_2 in
	let (r_4 ** (e_4, p_4)) = reorganize p _ e_3 in
	let (r_5 ** (e_5, p_5)) = simplifyAfterReorg_fix p _ e_4 in
	let (r_6 ** (e_6, p_6)) = elimZeroCG p _ e_5 in
            (_ ** (e_6, ?McommutativeGroupReduce_1))

		
buildProofCommutativeGroup : {c:Type} -> {n:Nat} -> (p:dataTypes.CommutativeGroup c) -> {setAndMult:SetWithMult c (commutativeGroup_to_set p)} -> {g:Vect n c} -> {x : c} -> {y : c} -> {c1:c} -> {c2:c} -> (ExprCG p setAndMult g c1) -> (ExprCG p setAndMult g c2) -> (x~=c1) -> (y~=c2) -> (Maybe (x~=y))
buildProofCommutativeGroup p e1 e2 lp rp with (exprCG_eq p _ _ e1 e2)
	buildProofCommutativeGroup p e1 e2 lp rp | Just e1_equiv_e2 = ?MbuildProofCommutativeGroup
	buildProofCommutativeGroup p e1 e2 lp rp | Nothing = Nothing

		
commutativeGroupDecideEq : {c:Type} -> {n:Nat} -> (p:dataTypes.CommutativeGroup c) -> {setAndMult:SetWithMult c (commutativeGroup_to_set p)} -> {g:Vect n c} -> {x : c} -> {y : c} -> (ExprCG p setAndMult g x) -> (ExprCG p setAndMult g y) -> (Maybe (x~=y))
-- e1 is the left side, e2 is the right side
commutativeGroupDecideEq p e1 e2 =
	let (r_e1 ** (e_e1, p_e1)) = commutativeGroupReduce p e1 in
	let (r_e2 ** (e_e2, p_e2)) = commutativeGroupReduce p e2 in
		buildProofCommutativeGroup p e_e1 e_e2 p_e1 p_e2	
		
		
---------- Proofs ----------
Provers.commutativeGroup_reduce.Massoc_and_commute_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus x y) z)
  exact (Plus x (Plus y z))
  mrefine set_eq_undec_refl 
  mrefine Plus_comm
  exact aux

Provers.commutativeGroup_reduce.Massoc_commute_and_assoc_1 = proof
  intros
  mrefine set_eq_undec_sym 
  mrefine eq_preserves_eq 
  exact (Plus (Plus x y) z)
  exact (Plus x (Plus y z))
  mrefine set_eq_undec_sym 
  mrefine set_eq_undec_sym 
  exact aux
  mrefine eq_preserves_eq 
  mrefine set_eq_undec_refl
  exact (Plus x (Plus y z))
  exact (Plus x (Plus y z))
  mrefine Plus_assoc 
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl
  mrefine set_eq_undec_refl
  mrefine Plus_comm

Provers.commutativeGroup_reduce.Massoc_commute_and_assoc_2 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus x (Plus y z))
  exact (Plus (Plus x z) y)
  exact aux
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  exact (Plus x (Plus z y))
  exact (Plus (Plus x z) y)
  exact aux2
  mrefine set_eq_undec_refl 
  exact aux3

Provers.commutativeGroup_reduce.Massoc_and_neutral_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus x (Neg x)) y)
  exact y
  exact aux
  mrefine set_eq_undec_refl
  mrefine eq_preserves_eq 
  exact (Plus Zero y)
  exact y
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl
  exact aux3
  exact aux2
  mrefine set_eq_undec_refl
  
Provers.commutativeGroup_reduce.Massoc_and_neutral_bis_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (Neg x) x) y)
  exact y
  exact aux
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  exact (Plus Zero y)
  exact y
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  exact aux3
  exact aux2
  mrefine set_eq_undec_refl 
    
Provers.commutativeGroup_reduce.MputVarOnPlace_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (index i0 g) c2) (index i g))
  exact (Plus (index i0 g) (Plus c2 (index i g)))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn
  
Provers.commutativeGroup_reduce.MputVarOnPlace_2 = proof
  intros
  mrefine Plus_comm 

Provers.commutativeGroup_reduce.MputVarOnPlace_3 = proof
  intros
  mrefine Plus_comm 
  
Provers.commutativeGroup_reduce.MputVarOnPlace_4 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (Neg (index i0 g)) c2) (index i g))
  exact (Plus (Neg (index i0 g)) (Plus c2 (index i g)))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc 
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn

Provers.commutativeGroup_reduce.MputVarOnPlace_5 = proof
  intros
  mrefine Plus_comm 

Provers.commutativeGroup_reduce.MputVarOnPlace_6 = proof
  intros
  mrefine Plus_comm

Provers.commutativeGroup_reduce.MputVarOnPlace_7 = proof
  intros
  mrefine Plus_comm   
  
Provers.commutativeGroup_reduce.MputVarOnPlace_8 = proof
  intros
  mrefine Plus_comm

Provers.commutativeGroup_reduce.MputVarOnPlace_9 = proof
  intros
  mrefine Plus_comm 
    
Provers.commutativeGroup_reduce.MputVarOnPlace_10 = proof
  intros
  mrefine Plus_comm   
  
Provers.commutativeGroup_reduce.MputConstantOnPlace_1 = proof
  intros
  mrefine assoc_commute_and_assoc 
  
Provers.commutativeGroup_reduce.MputConstantOnPlace_2 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (index i0 g) c2) constValue)
  exact (Plus (index i0 g) (Plus c2 constValue))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc 
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn
  
Provers.commutativeGroup_reduce.MputConstantOnPlace_3 = proof
  intros
  mrefine assoc_commute_and_assoc    

Provers.commutativeGroup_reduce.MputConstantOnPlace_4 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (Neg (index i0 g)) c2) constValue)
  exact (Plus (Neg (index i0 g)) (Plus c2 constValue))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn 

Provers.commutativeGroup_reduce.MputNegVarOnPlace_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (index i0 g) c2) (Neg (index i g)))
  exact (Plus (index i0 g) (Plus c2 (Neg (index i g))))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc 
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn 

Provers.commutativeGroup_reduce.MputNegVarOnPlace_2 = proof
  intros
  mrefine Plus_comm 

Provers.commutativeGroup_reduce.MputNegVarOnPlace_3 = proof
  intros
  mrefine Plus_comm 
  
Provers.commutativeGroup_reduce.MputNegVarOnPlace_4 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (Neg (index i0 g)) c2) (Neg (index i g)))
  exact (Plus (Neg (index i0 g)) (Plus c2 (Neg (index i g))))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc 
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn 
  
Provers.commutativeGroup_reduce.MputNegVarOnPlace_5 = proof
  intros
  mrefine Plus_comm 

Provers.commutativeGroup_reduce.MputNegVarOnPlace_6 = proof
  intros
  mrefine Plus_comm  
  
Provers.commutativeGroup_reduce.MputNegVarOnPlace_7 = proof
  intros
  mrefine Plus_comm   
  
Provers.commutativeGroup_reduce.MputNegVarOnPlace_8 = proof
  intros
  mrefine Plus_comm

Provers.commutativeGroup_reduce.MputNegVarOnPlace_9 = proof
  intros
  mrefine Plus_comm 
    
Provers.commutativeGroup_reduce.MputNegVarOnPlace_10 = proof
  intros
  mrefine Plus_comm     
  
Provers.commutativeGroup_reduce.MputNegConstantOnPlace_1 = proof
  intros
  mrefine assoc_commute_and_assoc 

Provers.commutativeGroup_reduce.MputNegConstantOnPlace_2 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (index i0 g) c2) (Neg constValue))
  exact (Plus (index i0 g) (Plus c2 (Neg constValue)))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_sym
  exact p_ihn 

Provers.commutativeGroup_reduce.MputNegConstantOnPlace_3 = proof
  intros
  mrefine assoc_commute_and_assoc
  
Provers.commutativeGroup_reduce.MputNegConstantOnPlace_4 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Plus (Neg (index i0 g)) c2) (Neg constValue))
  exact (Plus (Neg (index i0 g)) (Plus c2 (Neg constValue)))
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine Plus_assoc
  mrefine set_eq_undec_refl
  mrefine set_eq_undec_sym
  exact p_ihn   
  
Provers.commutativeGroup_reduce.Mreorganize_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (index i0 g) c2)
  exact r_add
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  exact (Plus c2 (index i0 g))
  exact r_add
  mrefine Plus_comm
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  exact (Plus r_ihn (index i0 g))
  exact r_add
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  exact p_add
  exact p_ihn 
  mrefine set_eq_undec_refl 
  
Provers.commutativeGroup_reduce.Mreorganize_2 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Neg (index i0 g)) r_ihn )
  exact r_add
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  mrefine set_eq_undec_refl 
  exact p_ihn
  exact (Plus r_ihn (Neg (index i0 g)))
  exact r_add
  mrefine Plus_comm
  mrefine set_eq_undec_refl 
  exact p_add

Provers.commutativeGroup_reduce.Mreorganize_3 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus c0 r_ihn)
  exact r_add
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  mrefine set_eq_undec_refl 
  exact p_ihn 
  exact (Plus r_ihn c0)
  exact r_add
  mrefine Plus_comm
  mrefine set_eq_undec_refl 
  exact p_add
  
Provers.commutativeGroup_reduce.Mreorganize_4 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Neg c0) r_ihn)
  exact r_add
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  mrefine set_eq_undec_refl 
  exact p_ihn 
  exact (Plus r_ihn (Neg c0))
  exact r_add
  mrefine Plus_comm
  mrefine set_eq_undec_refl 
  exact p_add

Provers.commutativeGroup_reduce.MsimplifyAfterReorg_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact c2
  exact r_ihn 
  mrefine assoc_and_neutral
  mrefine set_eq_undec_refl 
  exact p_ihn
    
Provers.commutativeGroup_reduce.MsimplifyAfterReorg_2 = proof
  intros
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  exact p_ihn 
  
Provers.commutativeGroup_reduce.MsimplifyAfterReorg_3 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Neg (index i0 g)) (Plus (index i0 g) r_ihn))
  exact r_ihn
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  mrefine assoc_and_neutral_bis 
  mrefine set_eq_undec_refl 
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  exact p_ihn 
  
Provers.commutativeGroup_reduce.MsimplifyAfterReorg_4 = proof
  intros
  mrefine eq_preserves_eq 
  exact (Plus (Neg (index i0 g)) r_ihn)
  exact (Plus (Neg (index i0 g)) r_ihn)
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_refl 
  mrefine set_eq_undec_refl 
  exact p_ihn 
  
Provers.commutativeGroup_reduce.MsimplifyAfterReorg_5 = proof
  intros
  mrefine Plus_preserves_equiv 
  mrefine set_eq_undec_refl 
  exact p_ihn
  
Provers.commutativeGroup_reduce.MsimplifyAfterReorg_6 = proof
  intros
  mrefine left
  exact (Plus (Neg (index i0 g)) (index i0 g) ~= Zero)
  mrefine Plus_inverse  
  
Provers.commutativeGroup_reduce.MsimplifyAfterReorg_7 = proof
  intros
  mrefine right
  exact (Plus (index i0 g) (Neg (index i0 g)) ~= Zero)
  mrefine Plus_inverse 

Provers.commutativeGroup_reduce.MsimplifyAfterReorg_fix_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact r_1
  exact r_1
  exact p_1
  mrefine set_eq_undec_sym 
  mrefine set_eq_undec_refl
  exact p_ih1

Provers.commutativeGroup_reduce.MelimZeroCG1 = proof
  intros
  mrefine add_zero_left 
  mrefine set_eq_undec_sym 
  exact const1_eq_zero 

Provers.commutativeGroup_reduce.MelimZeroCG2 = proof
  intros
  mrefine add_zero_right 
  mrefine set_eq_undec_sym 
  exact const2_eq_zero 
  
Provers.commutativeGroup_reduce.MelimZeroCG3 = proof
  intros
  mrefine Plus_preserves_equiv 
  exact p_ih1
  exact p_ih2
  
Provers.commutativeGroup_reduce.McommutativeGroupReduce_1 = proof
  intros
  mrefine eq_preserves_eq 
  exact r_2
  exact r_6
  exact p_2
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  exact r_4
  exact r_6
  exact p_4
  mrefine set_eq_undec_refl 
  mrefine eq_preserves_eq 
  exact r_5
  exact r_6
  exact p_5
  mrefine set_eq_undec_refl 
  exact p_6
  
Provers.commutativeGroup_reduce.MbuildProofCommutativeGroup = proof
  intros
  refine Just
  mrefine eq_preserves_eq 
  exact c1
  exact c2
  exact lp
  exact rp
  exact e1_equiv_e2 



  
  
