-- Edwin Brady, Franck Slama
-- University of St Andrews
-- File testNat.idr
-- Contain a test with Nat
-------------------------------------------------------------------

module testNat


import Prelude.Vect
import globalDef
import dataTypes
import reduceForCR

{-

-- WARNING : NAT IS NOT A GROUP (NO INVERSE !)
-- See if I can change my algorithm for doing normalisation for Nat too.


-- A simple test for the typeclass hierarchy
instance ZeroPlus Nat where
    Zero = O
    Plus x y = plus x y
        
instance {- ZeroPlus Nat => -} dataTypes.Group Nat where
    Plus_assoc x y z = ?Mplus_assoc_nat -- Will use the lemma plusAssociative
    Plus_neutral x = (?Mplus_neutral_nat_1, ?Mplus_neutral_nat_2)
    Plus_inverse x = ?Mplus_inverse_nat
    --Plus_inverse x = (?MV ** (?Mplus_inverse_nat_1, ?Mplus_inverse_nat_2))
    
instance CommutativeGroup Nat where
    Plus_comm x y = ?Mplus_comm_nat

instance OneMult Nat where
    One = S O
    Mult x y = mult x y
    
instance dataTypes.Ring Nat where
    Mult_assoc x y z = ?Mmult_assoc_nat    
    Mult_dist x y z = ?Mmult_dist_nat
    Mult_dist_2 x y z = ?Mmult_dist_nat_2
    Mult_neutral x = (?Mmult_neutral_nat_1, ?Mmult_neutral_nat_2)
    
instance CommutativeRing Nat where
    Mult_comm x y = ?Mmult_comm_nat


test1 : ExprCR (%instance) [O, S O] O 
test1 = VarCR _ fZ

test2 : ExprCR (%instance) [O, S O] (S O)
test2 = VarCR _ (fS fZ)

test3 : ExprCR (%instance) [O, S O]  (S O)
test3 = PlusCR (PlusCR test1 test2) (ConstCR _ O) -- Previously ZeroCR (when it was with zero and one instead of a general constant)


-- Test of a development
-------------------------
-- The original expression
test_e1_nat : ExprR (%instance) [O, S O, S (S O)] O
-- The expression is Mult (Plus x (Mult y (Plus 0 0)) z
test_e1_nat = MultR (PlusR (VarR _ fZ) (MultR (VarR _ (fS fZ)) (PlusR (ConstR _ O) (ConstR _ O)))) (VarR _ (fS (fS fZ)))
-- Printed
test_e1_nat_print : String
test_e1_nat_print = print_ExprR show test_e1


-- Function for printing the result of a transformation
print_transform : {c1:Nat} -> {c2:Nat} -> {g:Vect n Nat} -> (c2 ** (ExprR (%instance) g c2, c1=c2)) -> String
print_transform (val**(exp,pr)) = print_ExprR show exp -- WHY IMPOSSIBLE TO NAME "pr" BY "proof" ???

-- And now, the expression developped, printed
test_e1_dev_print : String
--test_e1_dev_print = print_transform (develop test_e1)


testNat.Mplus_assoc_nat = proof {
  intros;
  compute;
  mrefine sym;
  mrefine plusAssociative;
}

testNat.Mplus_neutral_nat_1 = proof {
  intros;
  compute;
  rewrite (plusZeroRightNeutral x);
  trivial;
}

testNat.Mplus_neutral_nat_2 = proof {
  intros;
  mrefine plusZeroRightNeutral;
}

-}