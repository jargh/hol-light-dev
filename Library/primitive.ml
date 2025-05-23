(* ========================================================================= *)
(* Existence of primitive roots modulo certain numbers.                      *)
(* ========================================================================= *)

needs "Library/integer.ml";;
needs "Library/isum.ml";;
needs "Library/binomial.ml";;
needs "Library/pocklington.ml";;
needs "Library/multiplicative.ml";;

(* ------------------------------------------------------------------------- *)
(* Lemma connecting concepts in the various background theories.             *)
(* ------------------------------------------------------------------------- *)

let INT_PRIME = prove
 (`!p. int_prime(&p) <=> prime p`,
  GEN_TAC THEN REWRITE_TAC[prime; int_prime] THEN
  ONCE_REWRITE_TAC[GSYM INT_DIVIDES_LABS] THEN
  REWRITE_TAC[GSYM INT_FORALL_ABS; GSYM num_divides; INT_ABS_NUM] THEN
  REWRITE_TAC[INT_OF_NUM_GT; INT_OF_NUM_EQ] THEN ASM_CASES_TAC `p = 0` THENL
   [ASM_REWRITE_TAC[ARITH; DIVIDES_0] THEN DISCH_THEN(MP_TAC o SPEC `2`);
    AP_THM_TAC THEN AP_TERM_TAC] THEN
  ASM_ARITH_TAC);;

(* ------------------------------------------------------------------------- *)
(* Explicit formula for difference of real/integer polynomials.              *)
(* ------------------------------------------------------------------------- *)

let REAL_POLY_DIFF_EXPLICIT = prove
 (`!n a x y.
        sum(0..n) (\i. a(i) * x pow i) - sum(0..n) (\i. a(i) * y pow i) =
        (x - y) *
        sum(0..n-1) (\i. sum(i+1..n) (\j. a j * y pow (j - 1 - i)) * x pow i)`,
  REPEAT GEN_TAC THEN
  REWRITE_TAC[GSYM SUM_SUB_NUMSEG; GSYM REAL_SUB_LDISTRIB] THEN
  MP_TAC(ISPEC `n:num` LE_0) THEN SIMP_TAC[SUM_CLAUSES_LEFT; ADD_CLAUSES] THEN
  DISCH_THEN(K ALL_TAC) THEN
  REWRITE_TAC[REAL_SUB_REFL; REAL_MUL_RZERO; REAL_ADD_LID; real_pow] THEN
  SIMP_TAC[REAL_SUB_POW] THEN
  ONCE_REWRITE_TAC[REAL_ARITH `a * b * c:real = b * a * c`] THEN
  REWRITE_TAC[SUM_LMUL] THEN AP_TERM_TAC THEN
  SIMP_TAC[GSYM SUM_LMUL; GSYM SUM_RMUL; SUM_SUM_PRODUCT; FINITE_NUMSEG] THEN
  MATCH_MP_TAC SUM_EQ_GENERAL_INVERSES THEN
  REPEAT(EXISTS_TAC `\(a:num,b:num). (b,a)`) THEN
  REWRITE_TAC[IN_ELIM_PAIR_THM; FORALL_PAIR_THM; REAL_MUL_AC] THEN
  REWRITE_TAC[IN_NUMSEG] THEN ARITH_TAC);;

let INT_POLY_DIFF_EXPLICIT = INT_OF_REAL_THM REAL_POLY_DIFF_EXPLICIT;;

(* ------------------------------------------------------------------------- *)
(* Lagrange's theorem on number of roots modulo a prime.                     *)
(* ------------------------------------------------------------------------- *)

let FINITE_INTSEG_RESTRICT = prove
 (`!P a b. FINITE {x:int | a <= x /\ x <= b /\ P x}`,
  SIMP_TAC[FINITE_RESTRICT; FINITE_INT_SEG; SET_RULE
   `{x | P x /\ Q x /\ R x} = {x | x IN {x | P x /\ Q x} /\ R x}`]);;

let INT_POLY_LAGRANGE = prove
 (`!p l r.
    int_prime p /\ r - l < p
    ==> !n a. ~(!i. i <= n ==> (a i == &0) (mod p))
              ==> CARD {x | l <= x /\ x <= r /\
                            (isum(0..n) (\i. a(i) * x pow i) == &0) (mod p)}
                  <= n`,
  REPEAT GEN_TAC THEN STRIP_TAC THEN REWRITE_TAC[INT_CONG_0_DIVIDES] THEN
  MATCH_MP_TAC num_WF THEN REPEAT STRIP_TAC THEN MATCH_MP_TAC(MESON[]
   `!a. (~(s = a) ==> CARD s <= n) /\ CARD a <= n ==> CARD s <= n`) THEN
  EXISTS_TAC `{}:int->bool` THEN REWRITE_TAC[LE_0; CARD_CLAUSES] THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM; IN_ELIM_THM] THEN
  X_GEN_TAC `c:int` THEN STRIP_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [MAP_EVERY UNDISCH_TAC
     [`~(!i:num. i <= n ==> (p:int) divides (a i))`;
      `p divides (isum (0..n) (\i. a i * c pow i))`] THEN
    ASM_SIMP_TAC[CONJUNCT1 LE; ISUM_CLAUSES_NUMSEG] THEN
    REWRITE_TAC[INT_POW; LEFT_FORALL_IMP_THM; EXISTS_REFL; INT_MUL_RID] THEN
    CONV_TAC TAUT;
    ALL_TAC] THEN
  ASM_CASES_TAC `p divides ((a:num->int) n)` THENL
   [ASM_SIMP_TAC[ISUM_CLAUSES_RIGHT; LE_0; LE_1] THEN
    ASM_SIMP_TAC[INTEGER_RULE
     `(p:int) divides y ==> (p divides (x + y * z) <=> p divides x)`] THEN
    MATCH_MP_TAC(ARITH_RULE `x <= n - 1 ==> x <= n`) THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `n - 1`) THEN
    ASM_REWRITE_TAC[ARITH_RULE `n - 1 < n <=> ~(n = 0)`] THEN
    DISCH_THEN MATCH_MP_TAC THEN
    ASM_MESON_TAC[ARITH_RULE `i <= n <=> i <= n - 1 \/ i = n`]; ALL_TAC] THEN
  MP_TAC(GEN `x:int` (MATCH_MP
     (INTEGER_RULE
       `a - b:int = c ==> p divides b ==> (p divides a <=> p divides c)`)
     (ISPECL [`n:num`; `a:num->int`; `x:int`; `c:int`]
             INT_POLY_DIFF_EXPLICIT))) THEN
  ASM_SIMP_TAC[INT_PRIME_DIVPROD_EQ] THEN DISCH_THEN(K ALL_TAC) THEN
  ASM_REWRITE_TAC[LEFT_OR_DISTRIB; SET_RULE
   `{x | q x \/ r x} = {x | q x} UNION {x | r x}`] THEN
  SUBGOAL_THEN
   `{x:int | l <= x /\ x <= r /\ p divides (x - c)} = {c}`
  SUBST1_TAC THENL
   [MATCH_MP_TAC(SET_RULE `P c /\ (!x y. P x /\ P y ==> x = y)
                           ==> {x | P x} = {c}`) THEN
    ASM_REWRITE_TAC[INT_SUB_REFL; INT_DIVIDES_0] THEN
    MAP_EVERY X_GEN_TAC [`u:int`; `v:int`] THEN STRIP_TAC THEN
    SUBGOAL_THEN `p divides (u - v:int)` MP_TAC THENL
     [ASM_MESON_TAC[INT_CONG; INT_CONG_SYM; INT_CONG_TRANS]; ALL_TAC] THEN
    DISCH_THEN(MP_TAC o MATCH_MP INT_DIVIDES_LE) THEN ASM_INT_ARITH_TAC;
    ALL_TAC] THEN
  REWRITE_TAC[SET_RULE `{a} UNION s = a INSERT s`] THEN
  SIMP_TAC[CARD_CLAUSES; FINITE_INTSEG_RESTRICT] THEN
  MATCH_MP_TAC(ARITH_RULE
   `~(n = 0) /\ x <= n - 1 ==> (if p then x else SUC x) <= n`) THEN
  ASM_REWRITE_TAC[] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[RIGHT_IMP_FORALL_THM; IMP_IMP]) THEN
  FIRST_ASSUM MATCH_MP_TAC THEN
  ASM_REWRITE_TAC[ARITH_RULE `n - 1 < n <=> ~(n = 0)`] THEN
  DISCH_THEN(MP_TAC o SPEC `n - 1`) THEN
  ASM_SIMP_TAC[LE_REFL; SUB_ADD; LE_1; ISUM_SING_NUMSEG; SUB_REFL] THEN
  ASM_REWRITE_TAC[INT_POW; INT_MUL_RID]);;

(* ------------------------------------------------------------------------- *)
(* Laborious instantiation to (x^d == 1) (mod p) over natural numbers.       *)
(* ------------------------------------------------------------------------- *)

let NUM_LAGRANGE_LEMMA = prove
 (`!p d. prime p /\ 1 <= d
         ==> CARD {x | x IN 1..p-1 /\ (x EXP d == 1) (mod p)} <= d`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`&p:int`; `&1:int`; `&(p-1):int`] INT_POLY_LAGRANGE) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[INT_PRIME; INT_LT_SUB_RADD; INT_OF_NUM_ADD; INT_OF_NUM_LT] THEN
    ARITH_TAC;
    ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPECL
   [`d:num`; `\i. if i = d then &1 else if i = 0 then -- &1 else &0:int`]) THEN
  REWRITE_TAC[] THEN ANTS_TAC THENL
   [DISCH_THEN(MP_TAC o SPEC `d:num`) THEN REWRITE_TAC[LE_REFL] THEN
    REWRITE_TAC[INT_CONG_0_DIVIDES; GSYM num_divides; DIVIDES_ONE] THEN
    ASM_MESON_TAC[PRIME_1];
    ALL_TAC] THEN
  REWRITE_TAC[MESON[]
   `(if p then x else y) * z:int = if p then x * z else y * z`] THEN
  SIMP_TAC[ISUM_CASES; FINITE_NUMSEG; FINITE_RESTRICT] THEN
  REWRITE_TAC[INT_POW; INT_MUL_LZERO; ISUM_0; INT_ADD_RID] THEN
  MATCH_MP_TAC(ARITH_RULE `x:num <= y ==> y <= d ==> x <= d`) THEN
  REWRITE_TAC[IN_ELIM_THM; IN_NUMSEG] THEN
  ASM_SIMP_TAC[ARITH_RULE `(0 <= i /\ i <= d) /\ i = d <=> i = d`;
               ARITH_RULE `1 <= d
                           ==> (((0 <= i /\ i <= d) /\ ~(i = d)) /\ i = 0 <=>
                                i = 0)`] THEN
  REWRITE_TAC[SING_GSPEC; ISUM_SING] THEN
  REWRITE_TAC[INT_ARITH `&1 * x + -- &1 * &1:int = x - &1`] THEN
  REWRITE_TAC[INTEGER_RULE `(x - a:int == &0) (mod p) <=>
                            (x == a) (mod p)`] THEN
  MATCH_MP_TAC CARD_SUBSET_IMAGE THEN EXISTS_TAC `num_of_int` THEN
  REWRITE_TAC[FINITE_INTSEG_RESTRICT; SUBSET; IN_IMAGE; IN_ELIM_THM] THEN
  X_GEN_TAC `n:num` THEN DISCH_TAC THEN EXISTS_TAC `&n:int` THEN
  ASM_REWRITE_TAC[NUM_OF_INT_OF_NUM; INT_OF_NUM_LE; INT_OF_NUM_POW] THEN
  ASM_REWRITE_TAC[GSYM num_congruent]);;

(* ------------------------------------------------------------------------- *)
(* Count of elements with a given order modulo a prime.                      *)
(* ------------------------------------------------------------------------- *)

let COUNT_ORDERS_MODULO_PRIME = prove
 (`!p d. prime p /\ d divides (p - 1)
         ==> CARD {x | x IN 1..p-1 /\ order p x = d} = phi(d)`,
  let lemma = prove
   (`!s f g:A->num.
          FINITE s /\ (!x. x IN s ==> f(x) <= g(x)) /\ nsum s f = nsum s g
          ==> !x. x IN s ==> f x = g x`,
    REWRITE_TAC[GSYM LE_ANTISYM] THEN MESON_TAC[NSUM_LE; NSUM_LT; NOT_LE]) in
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN GEN_TAC THEN DISCH_TAC THEN
  ONCE_REWRITE_TAC[SET_RULE
   `(!x. p x ==> q x) <=> (!x. x IN {x | p x} ==> q x)`] THEN
  MATCH_MP_TAC lemma THEN SUBGOAL_THEN `~(p - 1 = 0)` ASSUME_TAC THENL
   [FIRST_ASSUM(MP_TAC o MATCH_MP PRIME_GE_2) THEN ARITH_TAC; ALL_TAC] THEN
  ASM_SIMP_TAC[REWRITE_RULE[ETA_AX] PHI_DIVISORSUM; FINITE_DIVISORS] THEN
  CONJ_TAC THENL
   [ALL_TAC;
    SIMP_TAC[CARD_EQ_NSUM; FINITE_RESTRICT; FINITE_NUMSEG] THEN
    W(MP_TAC o PART_MATCH (lhs o rand) NSUM_GROUP o lhs o snd) THEN
    REWRITE_TAC[NSUM_CONST_NUMSEG; FINITE_NUMSEG; ADD_SUB; MULT_CLAUSES] THEN
    DISCH_THEN MATCH_MP_TAC THEN
    REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; IN_ELIM_THM; IN_NUMSEG] THEN
    X_GEN_TAC `x:num` THEN STRIP_TAC THEN ASM_SIMP_TAC[GSYM PHI_PRIME] THEN
    MATCH_MP_TAC ORDER_DIVIDES_PHI THEN ONCE_REWRITE_TAC[COPRIME_SYM] THEN
    MATCH_MP_TAC PRIME_COPRIME_LT THEN ASM_REWRITE_TAC[] THEN
    ASM_ARITH_TAC] THEN
  X_GEN_TAC `d:num` THEN REWRITE_TAC[IN_ELIM_THM] THEN DISCH_TAC THEN
  ASM_CASES_TAC `{x | x IN 1..p-1 /\ order p x = d} = {}` THEN
  ASM_REWRITE_TAC[CARD_CLAUSES; LE_0] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  REWRITE_TAC[IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN X_GEN_TAC `a:num` THEN
  REWRITE_TAC[IN_NUMSEG] THEN STRIP_TAC THEN REWRITE_TAC[PHI_ALT] THEN
  MATCH_MP_TAC CARD_SUBSET_IMAGE THEN EXISTS_TAC `\m. (a EXP m) MOD p` THEN
  REWRITE_TAC[PHI_FINITE_LEMMA] THEN
  SUBGOAL_THEN `1 <= d` ASSUME_TAC THENL
   [ASM_MESON_TAC[LE_1; DIVIDES_ZERO]; ALL_TAC] THEN
  SUBGOAL_THEN `coprime(p,a)` ASSUME_TAC THENL
   [ONCE_REWRITE_TAC[COPRIME_SYM] THEN
    MATCH_MP_TAC PRIME_COPRIME_LT THEN ASM_REWRITE_TAC[] THEN
    ASM_ARITH_TAC;
    ALL_TAC] THEN
  SUBGOAL_THEN
   `{x | x IN 1..p-1 /\ (x EXP d == 1) (mod p)} =
    IMAGE (\m. (a EXP m) MOD p) {m | m < d}`
  MP_TAC THENL
   [CONV_TAC SYM_CONV THEN MATCH_MP_TAC CARD_SUBSET_LE THEN
    SIMP_TAC[FINITE_RESTRICT; FINITE_NUMSEG] THEN CONJ_TAC THENL
     [REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; IN_ELIM_THM] THEN
      X_GEN_TAC `m:num` THEN DISCH_TAC THEN REWRITE_TAC[IN_NUMSEG] THEN
      ASM_SIMP_TAC[ARITH_RULE `~(p - 1 = 0) ==> (x <= p - 1 <=> x < p)`] THEN
      ASM_SIMP_TAC[DIVISION; PRIME_IMP_NZ] THEN CONJ_TAC THENL
       [REWRITE_TAC[ARITH_RULE `1 <= x <=> ~(x = 0)`] THEN
        ASM_SIMP_TAC[GSYM DIVIDES_MOD; PRIME_IMP_NZ] THEN
        ASM_MESON_TAC[PRIME_DIVEXP; PRIME_COPRIME_EQ];
        ASM_SIMP_TAC[CONG; PRIME_IMP_NZ; MOD_EXP_MOD] THEN
        REWRITE_TAC[EXP_EXP] THEN ONCE_REWRITE_TAC[MULT_SYM] THEN
        REWRITE_TAC[GSYM EXP_EXP] THEN
        SUBST1_TAC(SYM(SPEC `m:num` EXP_ONE)) THEN
        ASM_SIMP_TAC[GSYM CONG; PRIME_IMP_NZ] THEN
        MATCH_MP_TAC CONG_EXP THEN ASM_MESON_TAC[ORDER]];
      MATCH_MP_TAC LE_TRANS THEN EXISTS_TAC `d:num` THEN
      ASM_SIMP_TAC[NUM_LAGRANGE_LEMMA] THEN
      GEN_REWRITE_TAC LAND_CONV [GSYM CARD_NUMSEG_LT] THEN
      MATCH_MP_TAC EQ_IMP_LE THEN CONV_TAC SYM_CONV THEN
      MATCH_MP_TAC CARD_IMAGE_INJ THEN
      ASM_SIMP_TAC[GSYM CONG; PRIME_IMP_NZ; FINITE_NUMSEG_LT; IN_ELIM_THM] THEN
      ASM_SIMP_TAC[ORDER_DIVIDES_EXPDIFF] THEN REWRITE_TAC[CONG_IMP_EQ]];
    MATCH_MP_TAC(SET_RULE
     `s' SUBSET s /\ (!x. x IN t /\ f x IN s' ==> x IN t')
      ==> s = IMAGE f t ==> s' SUBSET IMAGE f t'`) THEN
    SIMP_TAC[SUBSET; IN_ELIM_THM; IN_NUMSEG] THEN
    CONJ_TAC THENL [MESON_TAC[ORDER]; ALL_TAC] THEN
    X_GEN_TAC `m:num` THEN ABBREV_TAC `b = (a EXP m) MOD p` THEN STRIP_TAC THEN
    REWRITE_TAC[coprime; divides] THEN X_GEN_TAC `e:num` THEN
    DISCH_THEN(CONJUNCTS_THEN2 (X_CHOOSE_THEN `m':num` (ASSUME_TAC o SYM))
                              (X_CHOOSE_THEN `d':num` (ASSUME_TAC o SYM))) THEN
    MP_TAC(ISPECL [`p:num`; `b:num`] ORDER_WORKS) THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (MP_TAC o SPEC `d':num`)) THEN
    ASM_REWRITE_TAC[] THEN
    MATCH_MP_TAC(TAUT `a /\ c /\ (~b ==> d) ==> (a /\ b ==> ~c) ==> d`) THEN
    REPEAT CONJ_TAC THENL
     [UNDISCH_TAC `1 <= d` THEN EXPAND_TAC "d" THEN
      REWRITE_TAC[ARITH_RULE `1 <= d <=> ~(d = 0)`; MULT_EQ_0] THEN
      SIMP_TAC[DE_MORGAN_THM; ARITH_RULE `0 < d <=> ~(d = 0)`];
      EXPAND_TAC "b" THEN ASM_SIMP_TAC[CONG; PRIME_IMP_NZ; MOD_EXP_MOD] THEN
      EXPAND_TAC "m" THEN REWRITE_TAC[EXP_EXP] THEN
      ONCE_REWRITE_TAC[ARITH_RULE `(e * m') * d':num = (e * d') * m'`] THEN
      ASM_REWRITE_TAC[] THEN REWRITE_TAC[GSYM EXP_EXP] THEN
      SUBST1_TAC(SYM(SPEC `m':num` EXP_ONE)) THEN
      ASM_SIMP_TAC[GSYM CONG; PRIME_IMP_NZ] THEN
      MATCH_MP_TAC CONG_EXP THEN ASM_MESON_TAC[ORDER];
      EXPAND_TAC "d" THEN
      REWRITE_TAC[ARITH_RULE `~(d < e * d) <=> e * d <= 1 * d`] THEN
      REWRITE_TAC[LE_MULT_RCANCEL] THEN
      REWRITE_TAC[ARITH_RULE `e <= 1 <=> e = 0 \/ e = 1`] THEN
      STRIP_TAC THEN UNDISCH_TAC `e * d':num = d` THEN
      ASM_REWRITE_TAC[] THEN ASM_ARITH_TAC]]);;

(* ------------------------------------------------------------------------- *)
(* In particular, primitive roots modulo a prime.                            *)
(* ------------------------------------------------------------------------- *)

let PRIMITIVE_ROOTS_MODULO_PRIME = prove
 (`!p. prime p ==> CARD {x | x IN 1..p-1 /\ order p x = p - 1} = phi(p - 1)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`p:num`; `p - 1`] COUNT_ORDERS_MODULO_PRIME) THEN
  ASM_REWRITE_TAC[DIVIDES_REFL]);;

let PRIMITIVE_ROOT_MODULO_PRIME = prove
 (`!p. prime p ==> ?x. x IN 1..p-1 /\ order p x = p - 1`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP PRIMITIVE_ROOTS_MODULO_PRIME) THEN
  ASM_CASES_TAC `{x | x IN 1..p-1 /\ order p x = p - 1} = {}` THENL
   [ASM_REWRITE_TAC[CARD_CLAUSES]; ASM SET_TAC[]] THEN
  ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN DISCH_THEN(K ALL_TAC) THEN
  MATCH_MP_TAC(ARITH_RULE `1 <= p ==> ~(0 = p)`) THEN
  MATCH_MP_TAC PHI_LOWERBOUND_1_STRONG THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP PRIME_GE_2) THEN ARITH_TAC);;

(* ------------------------------------------------------------------------- *)
(* Now primitive roots modulo odd prime powers.                              *)
(* ------------------------------------------------------------------------- *)

let COPRIME_1_PLUS_POWER_STEP = prove
 (`!p z k. prime p /\ coprime(z,p) /\ 3 <= p /\ 1 <= k
           ==> ?w. coprime(w,p) /\
                   (1 + z * p EXP k) EXP p = 1 + w * p EXP (k + 1)`,
  REPEAT STRIP_TAC THEN
  ONCE_REWRITE_TAC[ARITH_RULE `1 + a * b = a * b + 1`] THEN
  REWRITE_TAC[BINOMIAL_THEOREM; EXP_ONE; MULT_CLAUSES] THEN
  SIMP_TAC[NSUM_CLAUSES_LEFT; LE_0; EXP; binom; MULT_CLAUSES; ADD_CLAUSES] THEN
  SUBGOAL_THEN `1 <= p` MP_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
  SIMP_TAC[NSUM_CLAUSES_LEFT; BINOM_1; EXP_1; ARITH] THEN DISCH_TAC THEN
  SUBGOAL_THEN
   `(p EXP (k + 2)) divides (nsum(2..p) (\i. binom(p,i) * (z * p EXP k) EXP i))`
  MP_TAC THENL
   [ALL_TAC;
    REWRITE_TAC[divides; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `d:num` THEN DISCH_THEN SUBST1_TAC THEN
    EXISTS_TAC `z + p * d:num` THEN
    ASM_REWRITE_TAC[NUMBER_RULE
     `coprime(z + p * d:num,p) <=> coprime(z,p)`] THEN
    REWRITE_TAC[EXP_ADD] THEN ARITH_TAC] THEN
  MATCH_MP_TAC NSUM_CLOSED THEN
  REWRITE_TAC[DIVIDES_0; DIVIDES_ADD; IN_NUMSEG] THEN
  X_GEN_TAC `j:num` THEN STRIP_TAC THEN REWRITE_TAC[MULT_EXP] THEN
  ONCE_REWRITE_TAC[ARITH_RULE `a * b * c:num = b * c * a`] THEN
  REWRITE_TAC[EXP_EXP] THEN
  MATCH_MP_TAC DIVIDES_LMUL THEN ASM_CASES_TAC `j:num = p` THENL
   [MATCH_MP_TAC DIVIDES_RMUL THEN
    ASM_SIMP_TAC[DIVIDES_EXP_LE; ARITH_RULE `3 <= p ==> 2 <= p`] THEN
    MATCH_MP_TAC LE_TRANS THEN EXISTS_TAC `k * 3` THEN CONJ_TAC THENL
     [ASM_ARITH_TAC; ASM_REWRITE_TAC[LE_MULT_LCANCEL]];
    ONCE_REWRITE_TAC[MULT_SYM] THEN
    REWRITE_TAC[EXP; ARITH_RULE `k + 2 = SUC(k + 1)`] THEN
    MATCH_MP_TAC DIVIDES_MUL2 THEN CONJ_TAC THENL
     [MATCH_MP_TAC DIVIDES_PRIME_BINOM THEN ASM_REWRITE_TAC[] THEN
      ASM_ARITH_TAC;
      ASM_SIMP_TAC[DIVIDES_EXP_LE; ARITH_RULE `3 <= p ==> 2 <= p`] THEN
      MATCH_MP_TAC LE_TRANS THEN EXISTS_TAC `k * 2` THEN CONJ_TAC THENL
       [ASM_ARITH_TAC; ASM_REWRITE_TAC[LE_MULT_LCANCEL]]]]);;

let COPRIME_1_PLUS_POWER = prove
 (`!p z k. prime p /\ coprime(z,p) /\ 3 <= p
           ==> ?w. coprime(w,p) /\
                   (1 + z * p) EXP (p EXP k) = 1 + w * p EXP (k + 1)`,
  GEN_TAC THEN GEN_TAC THEN INDUCT_TAC THEN
  REWRITE_TAC[ADD_CLAUSES; EXP_1; EXP] THENL [MESON_TAC[]; ALL_TAC] THEN
  REWRITE_TAC[GSYM(ONCE_REWRITE_RULE[MULT_SYM] EXP_EXP)] THEN
  DISCH_THEN(fun th -> POP_ASSUM MP_TAC THEN STRIP_ASSUME_TAC th) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(X_CHOOSE_THEN `w:num` STRIP_ASSUME_TAC) THEN
  MP_TAC(ISPECL [`p:num`; `w:num`; `k + 1`] COPRIME_1_PLUS_POWER_STEP) THEN
  ASM_REWRITE_TAC[ARITH_RULE `1 <= k + 1`] THEN
  REWRITE_TAC[EXP_ADD; EXP_1; MULT_AC]);;

let PRIMITIVE_ROOT_MODULO_PRIMEPOWS = prove
 (`!p. prime p /\ 3 <= p
       ==> ?g. !j. 1 <= j ==> order(p EXP j) g = phi(p EXP j)`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP PRIMITIVE_ROOT_MODULO_PRIME) THEN
  REWRITE_TAC[IN_NUMSEG] THEN
  DISCH_THEN(X_CHOOSE_THEN `g:num` STRIP_ASSUME_TAC) THEN
  MP_TAC(ISPECL [`p:num`; `g:num`] ORDER) THEN
  ASM_SIMP_TAC[CONG_TO_1; EXP_EQ_0; LE_1] THEN
  DISCH_THEN(X_CHOOSE_THEN `y:num` STRIP_ASSUME_TAC) THEN
  SUBGOAL_THEN `?x. coprime(p,y + (p - 1) * g EXP (p - 2) * x)` CHOOSE_TAC THENL
   [MP_TAC(ISPECL [`(&p - &1:int) * &g pow (p - 2)`; `&1 - &y:int`; `&p:int`]
                  INT_CONG_SOLVE_POS) THEN
    ANTS_TAC THENL
     [REWRITE_TAC[INT_COPRIME_LMUL; INT_COPRIME_LPOW] THEN
      REWRITE_TAC[INTEGER_RULE `coprime(p - &1,p)`; GSYM num_coprime] THEN
      ASM_SIMP_TAC[INT_OF_NUM_EQ; ARITH_RULE `3 <= p ==> ~(p = 0)`] THEN
      DISJ1_TAC THEN MATCH_MP_TAC PRIME_COPRIME_LT THEN
      ASM_REWRITE_TAC[] THEN ASM_ARITH_TAC;
      REWRITE_TAC[GSYM INT_EXISTS_POS] THEN MATCH_MP_TAC MONO_EXISTS THEN
      GEN_TAC THEN DISCH_THEN(MP_TAC o MATCH_MP (INTEGER_RULE
       `(x:int == &1 - y) (mod n) ==> coprime(n,y + x)`)) THEN
      ASM_SIMP_TAC[INT_OF_NUM_SUB; INT_OF_NUM_POW; INT_OF_NUM_MUL;
                   INT_OF_NUM_ADD; GSYM num_coprime;
                    ARITH_RULE `3 <= p ==> 1 <= p`] THEN
      REWRITE_TAC[MULT_ASSOC]];
    ALL_TAC] THEN
  EXISTS_TAC `g + p * x:num` THEN X_GEN_TAC `j:num` THEN DISCH_TAC THEN
  STRIP_ASSUME_TAC(ISPECL [`p EXP j`; `g + p * x:num`] ORDER_WORKS) THEN
  MP_TAC(SPECL [`p:num`; `g + p * x:num`; `order (p EXP j) (g + p * x)`]
      ORDER_DIVIDES) THEN
  SUBGOAL_THEN `order p (g + p * x) = p - 1` SUBST1_TAC THENL
   [ASM_MESON_TAC[ORDER_CONG; NUMBER_RULE `(g:num == g + p * x) (mod p)`];
    ALL_TAC] THEN
  MATCH_MP_TAC(TAUT `a /\ (b ==> c) ==> (a <=> b) ==> c`) THEN CONJ_TAC THENL
   [MATCH_MP_TAC(NUMBER_RULE
     `!y. (a == 1) (mod y) /\ x divides y ==> (a == 1) (mod x)`) THEN
    EXISTS_TAC `p EXP j` THEN ASM_REWRITE_TAC[] THEN
    ASM_SIMP_TAC[DIVIDES_REFL; DIVIDES_REXP; LE_1];
    REWRITE_TAC[divides; LEFT_IMP_EXISTS_THM] THEN X_GEN_TAC `d:num` THEN
    DISCH_THEN(fun th -> SUBST_ALL_TAC th THEN ASSUME_TAC th)] THEN
  MP_TAC(ISPECL [`g + p * x:num`; `p EXP j`] ORDER_DIVIDES_PHI) THEN
  ASM_SIMP_TAC[PHI_PRIMEPOW; LE_1; COPRIME_LEXP] THEN ANTS_TAC THENL
   [REWRITE_TAC[NUMBER_RULE `coprime(p,g + p * x) <=> coprime(g,p)`] THEN
    MATCH_MP_TAC PRIME_COPRIME_LT THEN
    ASM_REWRITE_TAC[] THEN ASM_ARITH_TAC;
    ALL_TAC] THEN
  SUBGOAL_THEN `p EXP j - p EXP (j - 1) = (p - 1) * p EXP (j - 1)`
  SUBST1_TAC THENL
   [UNDISCH_TAC `1 <= j` THEN SPEC_TAC(`j:num`,`j:num`) THEN
    INDUCT_TAC THEN REWRITE_TAC[ARITH; SUC_SUB1] THEN
    REWRITE_TAC[EXP; RIGHT_SUB_DISTRIB] THEN ARITH_TAC;
    ALL_TAC] THEN
  DISCH_THEN(MP_TAC o MATCH_MP (NUMBER_RULE
   `(a * x:num) divides (a * y) ==> ~(a = 0) ==> x divides y`)) THEN
  ASM_SIMP_TAC[DIVIDES_PRIMEPOW; ARITH_RULE `3 <= p ==> ~(p - 1 = 0)`] THEN
  DISCH_THEN(X_CHOOSE_THEN `k:num`
   (CONJUNCTS_THEN2 ASSUME_TAC SUBST_ALL_TAC)) THEN
  AP_TERM_TAC THEN AP_TERM_TAC THEN
  SUBGOAL_THEN `?z. (g + p * x) EXP (p - 1) = 1 + z * p /\ coprime(z,p)`
  STRIP_ASSUME_TAC THENL
   [REWRITE_TAC[BINOMIAL_THEOREM] THEN
    ASM_SIMP_TAC[NSUM_CLAUSES_RIGHT; LE_0; ARITH_RULE
     `3 <= p ==> 0 < p - 1`] THEN
    REWRITE_TAC[BINOM_REFL; SUB_REFL; EXP; MULT_CLAUSES] THEN
    EXISTS_TAC
     `y + nsum(0..p-2) (\k. binom(p - 1,k) * g EXP k *
                            p EXP (p - 2 - k) * x EXP (p - 1 - k))` THEN
    REWRITE_TAC[ARITH_RULE `n - 1 - 1 = n - 2`] THEN
    SIMP_TAC[ARITH_RULE `s + 1 + y * p = 1 + (y + t) * p <=> s = p * t`] THEN
    CONJ_TAC THENL
     [REWRITE_TAC[GSYM NSUM_LMUL] THEN MATCH_MP_TAC NSUM_EQ THEN
      X_GEN_TAC `i:num` THEN REWRITE_TAC[IN_NUMSEG] THEN STRIP_TAC THEN
      SIMP_TAC[ARITH_RULE `p * b * g * pp * x:num = b * g * (p * pp) * x`] THEN
      AP_TERM_TAC THEN AP_TERM_TAC THEN REWRITE_TAC[MULT_EXP] THEN
      REWRITE_TAC[GSYM(CONJUNCT2 EXP)] THEN
      AP_THM_TAC THEN AP_TERM_TAC THEN AP_TERM_TAC THEN ASM_ARITH_TAC;
      ALL_TAC] THEN
    ASM_SIMP_TAC[NSUM_CLAUSES_RIGHT; LE_0; ARITH_RULE
     `3 <= p ==> 0 < p - 2`] THEN
    REWRITE_TAC[BINOM_REFL; SUB_REFL; EXP; MULT_CLAUSES] THEN
    ASM_SIMP_TAC[EXP_1; ARITH_RULE `3 <= p ==> p - 1 - (p - 2) = 1`] THEN
    SUBGOAL_THEN `binom(p - 1,p - 2) = p - 1` SUBST1_TAC THENL
     [SUBGOAL_THEN `p - 1 = SUC(p - 2)` SUBST1_TAC THENL
       [ASM_ARITH_TAC; REWRITE_TAC[BINOM_PENULT]];
      ALL_TAC] THEN
    MATCH_MP_TAC(NUMBER_RULE
     `coprime(p:num,y + x) /\ p divides z ==> coprime(y + z + x,p)`) THEN
    ASM_REWRITE_TAC[] THEN MATCH_MP_TAC NSUM_CLOSED THEN
    REWRITE_TAC[DIVIDES_0; DIVIDES_ADD; IN_NUMSEG] THEN
    X_GEN_TAC `i:num` THEN STRIP_TAC THEN
    REPLICATE_TAC 2 (MATCH_MP_TAC DIVIDES_LMUL) THEN
    MATCH_MP_TAC DIVIDES_RMUL THEN MATCH_MP_TAC DIVIDES_REXP THEN
    REWRITE_TAC[DIVIDES_REFL] THEN ASM_ARITH_TAC;
    ALL_TAC] THEN
  SUBGOAL_THEN
   `?w. (g + p * x) EXP ((p - 1) * p EXP k) = 1 + p EXP (k + 1) * w /\
        coprime(w,p)`
  STRIP_ASSUME_TAC THENL
   [ASM_REWRITE_TAC[GSYM EXP_EXP] THEN
    ONCE_REWRITE_TAC[CONJ_SYM] THEN
    GEN_REWRITE_TAC (BINDER_CONV o funpow 3 RAND_CONV) [MULT_SYM] THEN
    MATCH_MP_TAC COPRIME_1_PLUS_POWER THEN ASM_REWRITE_TAC[];
    UNDISCH_TAC
     `((g + p * x) EXP ((p - 1) * p EXP k) == 1) (mod (p EXP j))` THEN
    ASM_REWRITE_TAC[NUMBER_RULE `(1 + x == 1) (mod n) <=> n divides x`] THEN
    ONCE_REWRITE_TAC[MULT_SYM] THEN DISCH_TAC THEN
    MP_TAC(SPECL [`p:num`; `j:num`; `w:num`; `p EXP (k + 1)`]
       COPRIME_EXP_DIVPROD) THEN
    ONCE_REWRITE_TAC[COPRIME_SYM] THEN ASM_REWRITE_TAC[] THEN
    ASM_SIMP_TAC[DIVIDES_EXP_LE; ARITH_RULE `3 <= p ==> 2 <= p`] THEN
    UNDISCH_TAC `k <= j - 1` THEN ARITH_TAC]);;

let PRIMITIVE_ROOT_MODULO_PRIMEPOW = prove
 (`!p k. prime p /\ 3 <= p /\ 1 <= k
         ==> ?x. x IN 1..(p EXP k - 1) /\ order (p EXP k) x = phi(p EXP k)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPEC `p:num` PRIMITIVE_ROOT_MODULO_PRIMEPOWS) THEN
  ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `x:num` THEN DISCH_THEN(MP_TAC o SPEC `k:num`) THEN
  ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
  EXISTS_TAC `x MOD (p EXP k)` THEN CONJ_TAC THENL
   [REWRITE_TAC[IN_NUMSEG; ARITH_RULE `1 <= x <=> ~(x = 0)`] THEN
    CONJ_TAC THENL
     [MP_TAC(ISPECL [`p EXP k`; `x:num`] DIVIDES_MOD) THEN
      ASM_SIMP_TAC[EXP_EQ_0; ARITH_RULE `3 <= p ==> ~(p = 0)`] THEN
      DISCH_THEN(SUBST1_TAC o SYM) THEN DISCH_TAC THEN
      MP_TAC(ISPECL [`p EXP k`; `x:num`] ORDER) THEN
      DISCH_THEN(MP_TAC o MATCH_MP (NUMBER_RULE
       `(x == 1) (mod p) ==> p divides x ==> p divides 1`)) THEN
      ASM_SIMP_TAC[EXP_EQ_1; DIVIDES_ONE; LE_1] THEN
      ASM_SIMP_TAC[ARITH_RULE `3 <= p ==> ~(p = 1)`] THEN
      MATCH_MP_TAC DIVIDES_REXP THEN ASM_REWRITE_TAC[] THEN
      MATCH_MP_TAC(ARITH_RULE `1 <= p ==> ~(p = 0)`) THEN
      MATCH_MP_TAC PHI_LOWERBOUND_1_STRONG THEN
      MATCH_MP_TAC(ARITH_RULE `~(p = 0) ==> 1 <= p`) THEN
      ASM_SIMP_TAC[EXP_EQ_0] THEN ASM_ARITH_TAC;
      MATCH_MP_TAC(ARITH_RULE `a < b ==> a <= b - 1`) THEN
      MP_TAC(ISPECL [`x:num`; `p EXP k`] DIVISION) THEN
      ASM_SIMP_TAC[EXP_EQ_0; ARITH_RULE `3 <= p ==> ~(p = 0)`]];
    MATCH_MP_TAC EQ_TRANS THEN EXISTS_TAC `order (p EXP k) x` THEN
    CONJ_TAC THENL [ALL_TAC; ASM_REWRITE_TAC[]] THEN
    MATCH_MP_TAC ORDER_CONG THEN REWRITE_TAC[CONG_MOD]]);;

let PRIME_DIVISOR_ORDER_EXISTS = prove
 (`!n p. ~(n = 0) /\ prime p /\ p divides phi(n) ==> ?x. order n x = p`,
  GEN_REWRITE_TAC I [SWAP_FORALL_THM] THEN X_GEN_TAC `p:num` THEN
  ASM_CASES_TAC `prime p` THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC INDUCT_COPRIME_ALT THEN REWRITE_TAC[] THEN CONJ_TAC THENL
   [SIMP_TAC[ORDER_MUL_LCM; PHI_MULTIPLICATIVE; MULT_EQ_0] THEN
    ASM_SIMP_TAC[PRIME_DIVPROD_EQ; DE_MORGAN_THM; IMP_IMP; CONJ_ASSOC] THEN
    ONCE_REWRITE_TAC[IMP_CONJ_ALT] THEN MATCH_MP_TAC(MESON[]
     `(!x y. R x y <=> R y x) /\ (!x y. P x ==> R x y)
      ==> !x y. P x \/ P y ==> R x y`) THEN
    CONJ_TAC THENL [REWRITE_TAC[CONJ_ACI; COPRIME_SYM; LCM_SYM]; ALL_TAC] THEN
    MAP_EVERY X_GEN_TAC [`m:num`; `n:num`] THEN DISCH_TAC THEN
    MAP_EVERY ASM_CASES_TAC [`m = 0`; `n = 0`] THEN ASM_REWRITE_TAC[] THEN
    DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
    FIRST_X_ASSUM(K ALL_TAC o check (is_imp o concl)) THEN
    FIRST_X_ASSUM(X_CHOOSE_TAC `a:num`) THEN
    MP_TAC(ISPECL [`m:num`; `n:num`; `a:num`; `1`]
       CHINESE_REMAINDER_USUAL) THEN
    ASM_REWRITE_TAC[] THEN MATCH_MP_TAC MONO_EXISTS THEN
    X_GEN_TAC `b:num` THEN
    DISCH_THEN(CONJUNCTS_THEN(SUBST1_TAC o MATCH_MP ORDER_CONG)) THEN
    ASM_REWRITE_TAC[ORDER_1; LCM_1];
    MAP_EVERY X_GEN_TAC [`q:num`; `k:num`]] THEN
  ASM_CASES_TAC `k = 0` THENL
   [ASM_REWRITE_TAC[PHI_1; EXP; DIVIDES_ONE] THEN ASM_MESON_TAC[PRIME_1];
    ALL_TAC] THEN
  ASM_CASES_TAC `q = 2` THENL
   [ASM_SIMP_TAC[PHI_PRIMEPOW_ALT] THEN CONV_TAC NUM_REDUCE_CONV THEN
    ASM_SIMP_TAC[PRIME_DIVEXP_EQ; MULT_CLAUSES; DIVIDES_PRIME_PRIME] THEN
    REPEAT STRIP_TAC THEN EXISTS_TAC `2 EXP k - 1` THEN
    ASM_SIMP_TAC[ORDER_UNIQUE_PRIME; CONG_MINUS1_SQUARED] THEN
    DISCH_THEN(MP_TAC o MATCH_MP (NUMBER_RULE
     `(a == 1) (mod p) ==> (a + 1 == 2) (mod p)`)) THEN
    SIMP_TAC[SUB_ADD; LE_1; EXP_EQ_0; ARITH_EQ] THEN
    REWRITE_TAC[NUMBER_RULE `(p == 2) (mod p) <=> p divides 2 EXP 1`] THEN
    SIMP_TAC[DIVIDES_EXP_LE; LE_REFL] THEN ASM_ARITH_TAC;
    REPEAT STRIP_TAC] THEN
  MP_TAC(SPECL [`q:num`; `k:num`] PRIMITIVE_ROOT_MODULO_PRIMEPOW) THEN
  ASM_SIMP_TAC[LE_1] THEN ANTS_TAC THENL
   [ASM_MESON_TAC[ODD_PRIME; PRIME_ODD]; ALL_TAC] THEN
  DISCH_THEN(X_CHOOSE_THEN `x:num` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `x EXP (phi(q EXP k) DIV p)` THEN
  W(MP_TAC o PART_MATCH (lhand o rand) ORDER_EXP o lhand o snd) THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP DIVIDES_LE) THEN
  ASM_SIMP_TAC[DIV_BY_DIV; DIVIDES_DIV_SELF; PHI_EQ_0; DIV_EQ_0; NOT_LT;
               PRIME_IMP_NZ]);;

let INJECTIVE_EXP_MODULO_EQ = prove
 (`!n k. ~(n = 0)
         ==> ((!a b. coprime(n,a) /\ coprime(n,b) /\
                     (a EXP k == b EXP k) (mod n)
                     ==> (a == b) (mod n)) <=>
              coprime(k,phi n))`,
  REPEAT STRIP_TAC THEN
  EQ_TAC THENL [ALL_TAC; MESON_TAC[INJECTIVE_EXP_MODULO]] THEN
  GEN_REWRITE_TAC I [GSYM CONTRAPOS_THM] THEN
  GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [COPRIME_PRIME_EQ] THEN
  REWRITE_TAC[LEFT_IMP_EXISTS_THM; NOT_FORALL_THM] THEN
  X_GEN_TAC `p:num` THEN STRIP_TAC THEN REWRITE_TAC[NOT_IMP] THEN
  MP_TAC(ISPECL [`n:num`; `p:num`] PRIME_DIVISOR_ORDER_EXISTS) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC MONO_EXISTS THEN
  X_GEN_TAC `x:num` THEN STRIP_TAC THEN EXISTS_TAC `1` THEN
  ASM_REWRITE_TAC[COPRIME_1; EXP_ONE] THEN
  ASM_MESON_TAC[PRIME_0; PRIME_1; ORDER_EQ_0; ORDER_EQ_1; ORDER_DIVIDES]);;

let POWER_RESIDUE_MODULO_EQ_ALT = prove
 (`!n k. ~(n = 0)
         ==> ((!a. coprime(n,a)
                   ==> ?x. coprime(n,x) /\ (x EXP k == a) (mod n)) <=>
              coprime(k,phi n))`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`{a:num | a < n /\ coprime(n,a)}`; `\a. (a EXP k) MOD n`]
          SURJECTIVE_IFF_INJECTIVE) THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; IN_ELIM_THM] THEN
  ASM_REWRITE_TAC[GSYM CONJ_ASSOC; FORALL_LT_MOD_THM; EXISTS_LT_MOD_THM] THEN
  ANTS_TAC THENL
   [MATCH_MP_TAC FINITE_SUBSET THEN EXISTS_TAC `{a:num | a < n}` THEN
    REWRITE_TAC[FINITE_NUMSEG_LT] THEN SET_TAC[];
    REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; RIGHT_IMP_FORALL_THM]] THEN
  REWRITE_TAC[IN_ELIM_THM; IMP_IMP; GSYM CONJ_ASSOC; COPRIME_RMOD] THEN
  ASM_SIMP_TAC[MOD_LT_EQ; COPRIME_REXP] THEN CONV_TAC MOD_DOWN_CONV THEN
  REWRITE_TAC[GSYM CONG] THEN DISCH_THEN SUBST1_TAC THEN
  MATCH_MP_TAC INJECTIVE_EXP_MODULO_EQ THEN ASM_REWRITE_TAC[]);;

let POWER_RESIDUE_MODULO_EQ = prove
 (`!n k. ~(n = 0)
         ==> ((!a. coprime(n,a) ==> ?x. (x EXP k == a) (mod n)) <=>
              coprime(k,phi n))`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  FIRST_ASSUM(SUBST1_TAC o SYM o SPEC `k:num` o MATCH_MP
   POWER_RESIDUE_MODULO_EQ_ALT) THEN
  ASM_CASES_TAC `k = 0` THENL
   [ASM_REWRITE_TAC[EXP; COPRIME_0] THEN MESON_TAC[COPRIME_1]; ALL_TAC] THEN
  EQ_TAC THEN DISCH_TAC THEN X_GEN_TAC `a:num` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `a:num`) THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `x:num` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP CONG_COPRIME) THEN
  ASM_REWRITE_TAC[COPRIME_REXP]);;

(* ------------------------------------------------------------------------- *)
(* Double prime powers and the other remaining positive cases 2 and 4.       *)
(* ------------------------------------------------------------------------- *)

let PRIMITIVE_ROOT_MODULO_2 = prove
 (`?x. x IN 1..1 /\ order 2 x = phi(2)`,
  EXISTS_TAC `1` THEN REWRITE_TAC[IN_NUMSEG; ARITH] THEN
  SIMP_TAC[PHI_PRIME; PRIME_2] THEN CONV_TAC NUM_REDUCE_CONV THEN
  MATCH_MP_TAC ORDER_UNIQUE THEN
  REWRITE_TAC[ARITH_RULE `~(0 < m /\ m < 1)`] THEN
  CONV_TAC NUM_REDUCE_CONV THEN CONV_TAC(ONCE_DEPTH_CONV CONG_CONV) THEN
  REWRITE_TAC[]);;

let PRIMITIVE_ROOT_MODULO_4 = prove
 (`?x. x IN 1..3 /\ order 4 x = phi(4)`,
  EXISTS_TAC `3` THEN REWRITE_TAC[IN_NUMSEG; ARITH] THEN
  SUBST1_TAC(ARITH_RULE `4 = 2 EXP 2`) THEN
  SIMP_TAC[PHI_PRIMEPOW; PRIME_2] THEN CONV_TAC NUM_REDUCE_CONV THEN
  MATCH_MP_TAC ORDER_UNIQUE THEN
  REWRITE_TAC[FORALL_UNWIND_THM2; ARITH_RULE `0 < m /\ m < 2 <=> m = 1`] THEN
  CONV_TAC NUM_REDUCE_CONV THEN CONV_TAC(ONCE_DEPTH_CONV CONG_CONV) THEN
  REWRITE_TAC[]);;

let PRIMITIVE_ROOT_DOUBLE_LEMMA = prove
 (`!n a. ODD n /\ ODD a /\ order n a = phi n
         ==> order (2 * n) a = phi(2 * n)`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC ORDER_UNIQUE THEN
  ASM_SIMP_TAC[CONG_CHINESE_EQ; COPRIME_2; PHI_MULTIPLICATIVE] THEN
  REWRITE_TAC[PHI_2; MULT_CLAUSES] THEN REPEAT CONJ_TAC THENL
   [ASM_MESON_TAC[ODD; LE_1; PHI_LOWERBOUND_1_STRONG];
    ASM_REWRITE_TAC[GSYM ODD_MOD_2; ODD_EXP];
    ASM_MESON_TAC[ORDER_WORKS];
    ASM_MESON_TAC[ORDER_WORKS]]);;

let PRIMITIVE_ROOT_MODULO_DOUBLE_PRIMEPOW = prove
 (`!p k. prime p /\ 3 <= p /\ 1 <= k
         ==> ?x. x IN 1..(2 * p EXP k - 1) /\
                 order (2 * p EXP k) x = phi(2 * p EXP k)`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN MP_TAC(SPEC `p:num` PRIME_ODD) THEN
  ASM_SIMP_TAC[ARITH_RULE `3 <= p ==> ~(p = 2)`] THEN DISCH_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP PRIMITIVE_ROOT_MODULO_PRIMEPOW) THEN
  DISCH_THEN(X_CHOOSE_THEN `g:num` MP_TAC) THEN REWRITE_TAC[IN_NUMSEG] THEN
  STRIP_TAC THEN DISJ_CASES_TAC (SPEC `g:num` EVEN_OR_ODD) THENL
   [EXISTS_TAC `g + p EXP k` THEN CONJ_TAC THENL
     [CONJ_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
      MATCH_MP_TAC(ARITH_RULE
       `g <= x - 1 /\ p EXP 1 <= x ==> g + p <= 2 * x - 1`) THEN
      ASM_REWRITE_TAC[LE_EXP] THEN ASM_ARITH_TAC;
      ALL_TAC];
    EXISTS_TAC `g:num` THEN CONJ_TAC THENL [ASM_ARITH_TAC; ALL_TAC]] THEN
  MATCH_MP_TAC PRIMITIVE_ROOT_DOUBLE_LEMMA THEN
  ASM_REWRITE_TAC[ODD_ADD; ODD_EXP; NOT_ODD] THEN
  FIRST_X_ASSUM(SUBST1_TAC o SYM) THEN MATCH_MP_TAC ORDER_CONG THEN
  CONV_TAC NUMBER_RULE);;

(* ------------------------------------------------------------------------- *)
(* A couple of degenerate case not usually considered.                       *)
(* ------------------------------------------------------------------------- *)

let PRIMITIVE_ROOT_MODULO_0 = prove
 (`(?x. order 0 x = phi(0))`,
  EXISTS_TAC `2` THEN REWRITE_TAC[PHI_0; ORDER_EQ_0; COPRIME_2; ODD]);;

let PRIMITIVE_ROOT_MODULO_1 = prove
 (`?x. order 1 x = phi(1)`,
  EXISTS_TAC `1` THEN REWRITE_TAC[PHI_1] THEN MATCH_MP_TAC ORDER_UNIQUE THEN
  REWRITE_TAC[ARITH_RULE `0 < m /\ m < 1 <=> F`; EXP_1; CONG_REFL] THEN
  ARITH_TAC);;

(* ------------------------------------------------------------------------- *)
(* The negative results.                                                     *)
(* ------------------------------------------------------------------------- *)

let CONG_TO_1_POW2 = prove
 (`!k x. ODD x /\ 1 <= k ==> (x EXP (2 EXP k) == 1) (mod (2 EXP (k + 2)))`,
  INDUCT_TAC THEN REWRITE_TAC[ADD_CLAUSES; EXP] THEN
  CONV_TAC NUM_REDUCE_CONV THEN GEN_TAC THEN ASM_CASES_TAC `k = 0` THENL
   [ASM_REWRITE_TAC[] THEN CONV_TAC NUM_REDUCE_CONV THEN
    SIMP_TAC[ODD_EXISTS; LEFT_IMP_EXISTS_THM] THEN
    REPEAT STRIP_TAC THEN REWRITE_TAC[CONG_TO_1] THEN DISJ2_TAC THEN
    REWRITE_TAC[GSYM EVEN_EXISTS; ARITH_RULE
     `SUC(2 * m) EXP 2 = 1 + q * 8 <=> m * (m + 1) = 2 * q`] THEN
    REWRITE_TAC[EVEN_MULT; EVEN_ADD; ARITH] THEN CONV_TAC TAUT;
    STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o SPEC `x:num`) THEN
    ASM_SIMP_TAC[ONCE_REWRITE_RULE[MULT_SYM] EXP_MULT; LE_1] THEN
    REWRITE_TAC[CONG_TO_1; EXP_EQ_1; ADD_EQ_0; MULT_EQ_1] THEN
    CONV_TAC NUM_REDUCE_CONV THEN
    DISCH_THEN(X_CHOOSE_THEN `m:num` SUBST1_TAC) THEN
    REWRITE_TAC[EQ_MULT_LCANCEL; EXP_EQ_0; ARITH; GSYM EVEN_EXISTS; ARITH_RULE
     `(1 + m * n) EXP 2 = 1 + q * 2 * n <=>
      n * m * (2 + m * n) = n * 2 * q`] THEN
    REWRITE_TAC[EVEN_MULT; EVEN_ADD; EVEN_EXP; ARITH] THEN ARITH_TAC]);;

let NO_PRIMITIVE_ROOT_MODULO_POW2 = prove
 (`!k. 3 <= k ==> ~(?x. order (2 EXP k) x = phi(2 EXP k))`,
  REPEAT STRIP_TAC THEN DISJ_CASES_TAC(SPEC `x:num` EVEN_OR_ODD) THENL
   [FIRST_X_ASSUM(MP_TAC o MATCH_MP (ARITH_RULE
     `a = b ==> 1 <= b /\ a = 0 ==> F`)) THEN
    ASM_SIMP_TAC[ORDER_EQ_0; PHI_LOWERBOUND_1_STRONG; LE_1; EXP_EQ_0; ARITH;
                 COPRIME_LEXP; COPRIME_2; DE_MORGAN_THM; NOT_ODD] THEN
    ASM_ARITH_TAC;
    MP_TAC(CONJUNCT2(ISPECL [`2 EXP k`; `x:num`] ORDER_WORKS)) THEN
    ASM_REWRITE_TAC[] THEN
    DISCH_THEN(MP_TAC o SPEC `2 EXP (k - 2)`) THEN
    ASM_SIMP_TAC[PHI_PRIMEPOW; PRIME_2; ARITH_RULE `3 <= k ==> ~(k = 0)`] THEN
    ABBREV_TAC `j = k - 2` THEN
    SUBGOAL_THEN `k - 1 = j + 1` SUBST1_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
    SUBGOAL_THEN `k = j + 2` SUBST1_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
    SUBGOAL_THEN `1 <= j` ASSUME_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
    ASM_SIMP_TAC[CONG_TO_1_POW2; ARITH_RULE `0 < x <=> ~(x = 0)`] THEN
    REWRITE_TAC[EXP_EQ_0; ARITH] THEN
    MATCH_MP_TAC(ARITH_RULE `a + b:num < c ==> a < c - b`) THEN
    REWRITE_TAC[EXP_ADD] THEN CONV_TAC NUM_REDUCE_CONV THEN
    REWRITE_TAC[ARITH_RULE `x + x * 2 < x * 4 <=> ~(x = 0)`] THEN
    REWRITE_TAC[EXP_EQ_0; ARITH]]);;

let NO_PRIMITIVE_ROOT_MODULO_COMPOSITE = prove
 (`!a b. 3 <= a /\ 3 <= b /\ coprime(a,b)
         ==> ~(?x. order (a * b) x = phi(a * b))`,
  SIMP_TAC[PHI_MULTIPLICATIVE] THEN REPEAT STRIP_TAC THEN
  MP_TAC(SPECL [`a * b:num`; `x:num`] ORDER_WORKS) THEN
  ASM_SIMP_TAC[CONG_CHINESE_EQ] THEN STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `(phi a * phi b) DIV 2`) THEN
  REWRITE_TAC[ARITH_RULE `0 < a DIV 2 /\ a DIV 2 < a <=> 2 <= a`; NOT_IMP] THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC(ARITH_RULE `2 * 2 <= x ==> 2 <= x`) THEN
    MATCH_MP_TAC LE_MULT2 THEN ASM_SIMP_TAC[PHI_LOWERBOUND_2];
    SUBGOAL_THEN `EVEN(phi b)` MP_TAC THENL
     [ASM_SIMP_TAC[EVEN_PHI]; SIMP_TAC[EVEN_EXISTS; LEFT_IMP_EXISTS_THM]] THEN
    REWRITE_TAC[ARITH_RULE `(a * 2 * b) DIV 2 = a * b`];
    SUBGOAL_THEN `EVEN(phi a)` MP_TAC THENL
     [ASM_SIMP_TAC[EVEN_PHI]; SIMP_TAC[EVEN_EXISTS; LEFT_IMP_EXISTS_THM]] THEN
    REWRITE_TAC[ARITH_RULE `((2 * a) * b) DIV 2 = b * a`]] THEN
  X_GEN_TAC `m:num` THEN DISCH_THEN SUBST1_TAC THEN
  ASM_REWRITE_TAC[GSYM EXP_EXP] THEN SUBST1_TAC(SYM(SPEC `m:num` EXP_ONE)) THEN
  MATCH_MP_TAC CONG_EXP THEN MATCH_MP_TAC FERMAT_LITTLE THEN
  MP_TAC(ISPECL [`a * b:num`; `x:num`] ORDER_EQ_0) THEN
  ASM_SIMP_TAC[MULT_EQ_0; LE_1; PHI_LOWERBOUND_1_STRONG;
               ARITH_RULE `3 <= p ==> 1 <= p`] THEN
  CONV_TAC NUMBER_RULE);;

(* ------------------------------------------------------------------------- *)
(* Equivalences, one with some degenerate cases, one more conventional.      *)
(* ------------------------------------------------------------------------- *)

let PRIMITIVE_ROOT_EXISTS = prove
 (`!n. (?x. order n x = phi n) <=>
       n = 0 \/ n = 2 \/ n = 4 \/
       ?p k. prime p /\ 3 <= p /\ (n = p EXP k \/ n = 2 * p EXP k)`,
  GEN_TAC THEN
  ASM_CASES_TAC `n = 0` THEN ASM_REWRITE_TAC[PRIMITIVE_ROOT_MODULO_0] THEN
  ASM_CASES_TAC `n = 2` THENL
   [ASM_MESON_TAC[PRIMITIVE_ROOT_MODULO_2]; ALL_TAC] THEN
  ASM_CASES_TAC `n = 4` THENL
   [ASM_MESON_TAC[PRIMITIVE_ROOT_MODULO_4]; ALL_TAC] THEN
  ASM_REWRITE_TAC[] THEN ASM_CASES_TAC `n = 1` THENL
   [ASM_REWRITE_TAC[PRIMITIVE_ROOT_MODULO_1] THEN
    MAP_EVERY EXISTS_TAC [`3`; `0`] THEN
    CONV_TAC(ONCE_DEPTH_CONV PRIME_CONV) THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN
  EQ_TAC THENL
   [ALL_TAC;
    REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
    MAP_EVERY X_GEN_TAC [`p:num`; `k:num`] THEN
    ASM_CASES_TAC `k = 0` THEN ASM_REWRITE_TAC[EXP; MULT_CLAUSES] THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    ASM_MESON_TAC[LE_1; PRIMITIVE_ROOT_MODULO_PRIMEPOW;
                  PRIMITIVE_ROOT_MODULO_DOUBLE_PRIMEPOW]] THEN
  ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
  REWRITE_TAC[NOT_EXISTS_THM; TAUT `~(a /\ b /\ c) <=> a /\ b ==> ~c`] THEN
  REWRITE_TAC[DE_MORGAN_THM] THEN STRIP_TAC THEN
  MP_TAC(ISPEC `n:num` PRIMEPOW_FACTOR) THEN
  ANTS_TAC THENL [ASM_ARITH_TAC; REWRITE_TAC[LEFT_IMP_EXISTS_THM]] THEN
  MAP_EVERY X_GEN_TAC [`p:num`; `k:num`; `m:num`] THEN
  ASM_CASES_TAC `m = 0` THEN ASM_REWRITE_TAC[MULT_CLAUSES] THEN
  ASM_CASES_TAC `m = 1` THENL
   [ASM_REWRITE_TAC[MULT_CLAUSES] THEN
    REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    DISCH_THEN SUBST_ALL_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`p:num`; `k:num`]) THEN
    ASM_SIMP_TAC[PRIME_GE_2; ARITH_RULE
     `2 <= p ==> (~(3 <= p) <=> p = 2)`] THEN
    DISCH_THEN SUBST_ALL_TAC THEN ASM_CASES_TAC `3 <= k` THENL
     [ASM_MESON_TAC[NO_PRIMITIVE_ROOT_MODULO_POW2]; ALL_TAC] THEN
    FIRST_X_ASSUM(MP_TAC o MATCH_MP (ARITH_RULE
      `~(3 <= k) ==> 1 <= k ==> k = 1 \/ k = 2`)) THEN
    ASM_REWRITE_TAC[] THEN DISCH_THEN(DISJ_CASES_THEN SUBST_ALL_TAC) THEN
    REPEAT(POP_ASSUM MP_TAC) THEN CONV_TAC NUM_REDUCE_CONV;
    ALL_TAC] THEN
  ASM_CASES_TAC `m = 2` THENL
   [ASM_REWRITE_TAC[COPRIME_2] THEN
    ASM_CASES_TAC `p = 2` THEN ASM_REWRITE_TAC[ARITH] THEN
    STRIP_TAC THEN FIRST_ASSUM(ASSUME_TAC o MATCH_MP PRIME_GE_2) THEN
    SUBGOAL_THEN `3 <= p` ASSUME_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
    ASM_MESON_TAC[MULT_SYM];
    ALL_TAC] THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  ASM_CASES_TAC `k = 1` THENL
   [UNDISCH_THEN `k = 1` SUBST_ALL_TAC;
    MP_TAC(SPECL [`p EXP k`; `m:num`] NO_PRIMITIVE_ROOT_MODULO_COMPOSITE) THEN
    REWRITE_TAC[NOT_EXISTS_THM] THEN DISCH_THEN MATCH_MP_TAC THEN
    ASM_REWRITE_TAC[COPRIME_LEXP] THEN
    CONJ_TAC THENL [ALL_TAC; ASM_ARITH_TAC] THEN
    MATCH_MP_TAC(ARITH_RULE `2 EXP 2 <= x ==> 3 <= x`) THEN
    MATCH_MP_TAC LE_TRANS THEN EXISTS_TAC `p EXP 2` THEN
    ASM_REWRITE_TAC[EXP_MONO_LE; LE_EXP] THEN
    ASM_SIMP_TAC[PRIME_GE_2; PRIME_IMP_NZ] THEN ASM_ARITH_TAC] THEN
  ASM_CASES_TAC `p = 2` THENL
   [UNDISCH_THEN `p = 2` SUBST_ALL_TAC;
    MP_TAC(SPECL [`p EXP 1`; `m:num`] NO_PRIMITIVE_ROOT_MODULO_COMPOSITE) THEN
    REWRITE_TAC[NOT_EXISTS_THM] THEN DISCH_THEN MATCH_MP_TAC THEN
    ASM_REWRITE_TAC[COPRIME_LEXP] THEN REWRITE_TAC[EXP_1] THEN
    FIRST_ASSUM(MP_TAC o MATCH_MP PRIME_GE_2) THEN ASM_ARITH_TAC] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[EXP_1]) THEN REWRITE_TAC[EXP_1] THEN
  MP_TAC(ISPEC `m:num` PRIMEPOW_FACTOR) THEN
  ANTS_TAC THENL [ASM_ARITH_TAC; REWRITE_TAC[LEFT_IMP_EXISTS_THM]] THEN
  MAP_EVERY X_GEN_TAC [`q:num`; `j:num`; `r:num`] THEN
  ASM_CASES_TAC `r = 0` THEN ASM_REWRITE_TAC[MULT_CLAUSES] THEN
  STRIP_TAC THEN UNDISCH_TAC `coprime(2,m)` THEN
  ASM_SIMP_TAC[COPRIME_RMUL; COPRIME_REXP; LE_1] THEN
  REWRITE_TAC[COPRIME_2] THEN STRIP_TAC THEN
  SUBGOAL_THEN `3 <= q` ASSUME_TAC THENL
   [MATCH_MP_TAC(ARITH_RULE `~(p = 2) /\ 2 <= p ==> 3 <= p`) THEN
    ASM_SIMP_TAC[PRIME_GE_2] THEN DISCH_TAC THEN
    UNDISCH_TAC `ODD q` THEN ASM_REWRITE_TAC[ARITH];
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o SPECL [`q:num`; `j:num`]) THEN
  ASM_CASES_TAC `r = 1` THEN ASM_REWRITE_TAC[MULT_CLAUSES] THEN STRIP_TAC THEN
  MP_TAC(SPECL [`2 * r`; `q EXP j`] NO_PRIMITIVE_ROOT_MODULO_COMPOSITE) THEN
  REWRITE_TAC[COPRIME_LMUL; COPRIME_REXP] THEN ASM_REWRITE_TAC[COPRIME_2] THEN
  ONCE_REWRITE_TAC[COPRIME_SYM] THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[MULT_AC; NOT_EXISTS_THM] THEN DISCH_THEN MATCH_MP_TAC THEN
  ASM_REWRITE_TAC[ARITH_RULE `3 <= r * 2 <=> ~(r = 0 \/ r = 1)`] THEN
  MATCH_MP_TAC LE_TRANS THEN EXISTS_TAC `q EXP 1` THEN
  ASM_REWRITE_TAC[LE_EXP; ARITH; COND_ID] THEN ASM_REWRITE_TAC[EXP_1]);;

let PRIMITIVE_ROOT_EXISTS_NONTRIVIAL = prove
 (`!n. (?x. x IN 1..n-1 /\ order n x = phi n) <=>
       n = 2 \/ n = 4 \/
       ?p k. prime p /\ 3 <= p /\ 1 <= k /\ (n = p EXP k \/ n = 2 * p EXP k)`,
  GEN_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [ASM_REWRITE_TAC[IN_NUMSEG] THEN CONV_TAC NUM_REDUCE_CONV THEN
    MATCH_MP_TAC(TAUT `~a /\ ~b ==> (a <=> b)`) THEN
    CONV_TAC(ONCE_DEPTH_CONV SYM_CONV) THEN
    REWRITE_TAC[MULT_EQ_0; EXP_EQ_0] THEN ARITH_TAC;
    ALL_TAC] THEN
  ASM_CASES_TAC `n = 1` THENL
   [ASM_REWRITE_TAC[IN_NUMSEG] THEN CONV_TAC NUM_REDUCE_CONV THEN
    MATCH_MP_TAC(TAUT `~a /\ ~b ==> (a <=> b)`) THEN
    CONV_TAC(ONCE_DEPTH_CONV SYM_CONV) THEN
    REWRITE_TAC[MULT_EQ_1; EXP_EQ_1] THEN ARITH_TAC;
    ALL_TAC] THEN
  MATCH_MP_TAC EQ_TRANS THEN
  EXISTS_TAC `?x. order n x = phi n` THEN CONJ_TAC THENL
   [EQ_TAC THENL [MESON_TAC[]; ALL_TAC] THEN
    DISCH_THEN(X_CHOOSE_TAC `x:num`) THEN EXISTS_TAC `x MOD n` THEN
    ASM_SIMP_TAC[IN_NUMSEG; DIVISION; ARITH_RULE
     `~(n = 0) /\ ~(n = 1) ==> (x <= n - 1 <=> x < n)`] THEN
    CONJ_TAC THENL
     [REWRITE_TAC[ARITH_RULE `1 <= x <=> ~(x = 0)`] THEN
      ASM_SIMP_TAC[GSYM DIVIDES_MOD] THEN DISCH_TAC THEN
      MP_TAC(SPECL [`n:num`; `x:num`] ORDER_EQ_0) THEN
      ASM_SIMP_TAC[LE_1; PHI_LOWERBOUND_1_STRONG] THEN
      REWRITE_TAC[coprime] THEN DISCH_THEN(MP_TAC o SPEC `n:num`) THEN
      ASM_REWRITE_TAC[DIVIDES_REFL];
      FIRST_ASSUM(SUBST1_TAC o SYM) THEN MATCH_MP_TAC ORDER_CONG THEN
      ASM_SIMP_TAC[CONG_MOD]];
    ASM_REWRITE_TAC[PRIMITIVE_ROOT_EXISTS] THEN
    ASM_CASES_TAC `n = 2` THEN ASM_REWRITE_TAC[] THEN
    ASM_CASES_TAC `n = 4` THEN ASM_REWRITE_TAC[] THEN
    AP_TERM_TAC THEN REWRITE_TAC[FUN_EQ_THM] THEN X_GEN_TAC `p:num` THEN
    AP_TERM_TAC THEN REWRITE_TAC[FUN_EQ_THM] THEN X_GEN_TAC `k:num` THEN
    CONV_TAC(BINOP_CONV(ONCE_DEPTH_CONV SYM_CONV)) THEN
    ASM_CASES_TAC `k = 0` THEN ASM_SIMP_TAC[LE_1] THEN
    AP_TERM_TAC THEN ASM_ARITH_TAC]);;

(* ------------------------------------------------------------------------- *)
(* If there are any primitive roots mod n, there are exactly phi(phi n).     *)
(* ------------------------------------------------------------------------- *)

let COUNT_PRIMITIVE_ROOTS_ALT = prove
 (`!n. {a | a < n /\ coprime(n,a) /\ order n a = phi n} HAS_SIZE
       (if n = 0 \/ n = 2 \/ n = 4 \/
           ?p k. prime p /\ 3 <= p /\ (n = p EXP k \/ n = 2 * p EXP k)
        then phi(phi n) else 0)`,
  GEN_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [ASM_REWRITE_TAC[LT; PHI_0; COND_ID; EMPTY_GSPEC] THEN
    REWRITE_TAC[HAS_SIZE; CARD_CLAUSES; FINITE_EMPTY];
    REWRITE_TAC[GSYM PRIMITIVE_ROOT_EXISTS]] THEN
  COND_CASES_TAC THENL
   [FIRST_X_ASSUM(X_CHOOSE_TAC `g:num`);
    RULE_ASSUM_TAC(REWRITE_RULE[NOT_EXISTS_THM]) THEN
    ASM_REWRITE_TAC[EMPTY_GSPEC; HAS_SIZE; CARD_CLAUSES; FINITE_EMPTY]] THEN
  SUBGOAL_THEN `coprime(n:num,g)` ASSUME_TAC THENL
   [ASM_MESON_TAC[ORDER_EQ_0; PHI_EQ_0]; ALL_TAC] THEN
  ONCE_REWRITE_TAC[SET_RULE
   `{x | P x /\ Q x /\ R x} = {x | x IN {y | P y /\ Q y} /\ R x}`] THEN
  MATCH_MP_TAC(ISPEC `\i. (g EXP i) MOD n` HAS_SIZE_IMAGE_INJ_RESTRICT) THEN
  EXISTS_TAC `{i | i < phi n}` THEN
  REWRITE_TAC[IN_ELIM_THM; FINITE_NUMSEG_LT; CARD_NUMSEG_LT] THEN
  REPEAT CONJ_TAC THENL
   [ONCE_REWRITE_TAC[SET_RULE
     `{x | P x /\ Q x} = {x | x IN {y | P y} /\ Q x}`] THEN
    SIMP_TAC[FINITE_RESTRICT; FINITE_NUMSEG_LT];
    ONCE_REWRITE_TAC[COPRIME_SYM] THEN REWRITE_TAC[PHI_ALT] THEN
    AP_TERM_TAC THEN SET_TAC[];
    ASM_REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; IN_ELIM_THM; MOD_LT_EQ] THEN
    ASM_REWRITE_TAC[COPRIME_REXP; COPRIME_RMOD];
    REWRITE_TAC[GSYM CONG] THEN ASM_SIMP_TAC[ORDER_DIVIDES_EXPDIFF] THEN
    REWRITE_TAC[CONG_IMP_EQ];
    REWRITE_TAC[ORDER_MOD]] THEN
  SUBGOAL_THEN
   `{a | a < phi n /\ order n (g EXP a) = phi n} =
    {a | coprime(a,phi n) /\ a < phi n}`
  SUBST1_TAC THENL
   [ALL_TAC;
    REWRITE_TAC[HAS_SIZE; GSYM PHI_ALT] THEN
    MATCH_MP_TAC FINITE_SUBSET THEN EXISTS_TAC `{a | a < phi n}` THEN
    REWRITE_TAC[FINITE_NUMSEG_LT] THEN SET_TAC[]] THEN
  GEN_REWRITE_TAC I [EXTENSION] THEN X_GEN_TAC `a:num` THEN
  REWRITE_TAC[IN_ELIM_THM] THEN
  ASM_CASES_TAC `a < phi n` THEN ASM_REWRITE_TAC[ORDER_EXP_GEN] THEN
  COND_CASES_TAC THENL [ASM_MESON_TAC[COPRIME_0]; ALL_TAC] THEN
  GEN_REWRITE_TAC RAND_CONV [COPRIME_SYM] THEN EQ_TAC THEN
  SIMP_TAC[GCD_ONE; DIV_1] THEN
  MP_TAC(NUMBER_RULE `gcd(phi n,a) divides phi n`) THEN
  REWRITE_TAC[divides; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `e:num` THEN ABBREV_TAC `d = gcd(phi n,a)` THEN
  DISCH_THEN(fun th -> SUBST1_TAC th THEN ASSUME_TAC(SYM th)) THEN
  ASM_CASES_TAC `d = 0` THENL
   [ASM_MESON_TAC[MULT_CLAUSES; PHI_EQ_0]; ALL_TAC] THEN
  ASM_SIMP_TAC[DIV_MULT] THEN DISCH_THEN SUBST_ALL_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP (NUM_RING `d * p = p ==> d = 1 \/ p = 0`)) THEN
  ASM_REWRITE_TAC[PHI_EQ_0; COPRIME_GCD]);;

let COUNT_PRIMITIVE_ROOTS = prove
 (`!n. {x | x < n /\ order n x = phi n} HAS_SIZE
       (if n = 0 \/ n = 2 \/ n = 4 \/
           ?p k. prime p /\ 3 <= p /\ (n = p EXP k \/ n = 2 * p EXP k)
        then phi(phi n) else 0)`,
  GEN_TAC THEN MP_TAC(SPEC `n:num` COUNT_PRIMITIVE_ROOTS_ALT) THEN
  MATCH_MP_TAC EQ_IMP THEN AP_THM_TAC THEN AP_TERM_TAC THEN
  REWRITE_TAC[EXTENSION; IN_ELIM_THM] THEN
  MESON_TAC[ORDER_EQ_0; PHI_EQ_0; LT]);;

(* ------------------------------------------------------------------------- *)
(* Counting roots, roots of unity and power residues.                        *)
(* ------------------------------------------------------------------------- *)

let COUNT_ROOTS_MODULO_PRIMITIVE_GEN_ALT = prove
 (`!n a k.
        ~(n = 0) /\ (?x. order n x = phi n)
        ==> {x | x < n /\ coprime(n,x) /\ (x EXP k == a) (mod n)} HAS_SIZE
            (if (a EXP (phi n DIV gcd(k,phi n)) == 1) (mod n)
             then gcd(k,phi n) else 0)`,
  REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  ASM_CASES_TAC `k = 0` THENL
   [DISCH_THEN(K ALL_TAC) THEN
    ASM_SIMP_TAC[GCD_0; DIV_REFL; PHI_EQ_0; EXP_1; EXP] THEN
    ONCE_REWRITE_TAC[NUMBER_RULE `(1 == a) (mod n) <=> (a == 1) (mod n)`] THEN
    ASM_CASES_TAC `(a == 1) (mod n)` THEN
    ASM_REWRITE_TAC[EMPTY_GSPEC; HAS_SIZE; FINITE_EMPTY; CARD_CLAUSES] THEN
    CONJ_TAC THENL
     [MATCH_MP_TAC FINITE_SUBSET THEN EXISTS_TAC `{x:num | x < n}` THEN
      REWRITE_TAC[FINITE_NUMSEG_LT] THEN SET_TAC[];
      ONCE_REWRITE_TAC[CONJ_SYM] THEN ONCE_REWRITE_TAC[COPRIME_SYM] THEN
      REWRITE_TAC[PHI_ALT]];
    DISCH_THEN(X_CHOOSE_TAC `g:num`)] THEN
  ASM_CASES_TAC `coprime(n:num,a)` THENL
   [ALL_TAC;
    ONCE_REWRITE_TAC[MESON[CONG_COPRIME]
     `(x == a) (mod n) <=>
      (x == a) (mod n) /\ (coprime(n,x) <=> coprime(n,a))`] THEN
    ASM_REWRITE_TAC[COPRIME_REXP; COPRIME_1] THEN
    ASM_SIMP_TAC[DIV_EQ_0; GCD_ZERO] THEN
    ASM_REWRITE_TAC[GSYM NOT_LE; GCD_LE; PHI_EQ_0; HAS_SIZE_0] THEN
    SET_TAC[]] THEN
  SUBGOAL_THEN `coprime(n:num,g)` ASSUME_TAC THENL
   [ASM_MESON_TAC[ORDER_EQ_0; PHI_EQ_0]; ALL_TAC] THEN
  ONCE_REWRITE_TAC[SET_RULE
   `{x | P x /\ Q x /\ R x} = {x | x IN {y | P y /\ Q y} /\ R x}`] THEN
  MATCH_MP_TAC(ISPEC `\i. (g EXP i) MOD n` HAS_SIZE_IMAGE_INJ_RESTRICT) THEN
  EXISTS_TAC `{i | i < phi n}` THEN
  REWRITE_TAC[IN_ELIM_THM; FINITE_NUMSEG_LT; CARD_NUMSEG_LT] THEN
  REPEAT CONJ_TAC THENL
   [ONCE_REWRITE_TAC[SET_RULE
     `{x | P x /\ Q x} = {x | x IN {y | P y} /\ Q x}`] THEN
    SIMP_TAC[FINITE_RESTRICT; FINITE_NUMSEG_LT];
    ONCE_REWRITE_TAC[COPRIME_SYM] THEN REWRITE_TAC[PHI_ALT] THEN
    AP_TERM_TAC THEN SET_TAC[];
    ASM_REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; IN_ELIM_THM; MOD_LT_EQ] THEN
    ASM_REWRITE_TAC[COPRIME_REXP; COPRIME_RMOD];
    REWRITE_TAC[GSYM CONG] THEN ASM_SIMP_TAC[ORDER_DIVIDES_EXPDIFF] THEN
    REWRITE_TAC[CONG_IMP_EQ];
    REWRITE_TAC[CONG; MOD_EXP_MOD] THEN REWRITE_TAC[GSYM CONG; EXP_EXP]] THEN
  SUBGOAL_THEN `?r. r < phi n /\ (g EXP r == a) (mod n)` STRIP_ASSUME_TAC THENL
   [MP_TAC(ISPECL [`{i | i < phi n}`; `{x:num | x < n /\ coprime(n,x)}`;
             `\i. (g EXP i) MOD n`] SURJECTIVE_IFF_INJECTIVE_GEN) THEN
    REWRITE_TAC[IN_ELIM_THM; FINITE_NUMSEG_LT; CARD_NUMSEG_LT] THEN
    ANTS_TAC THENL
     [REPEAT CONJ_TAC THENL
       [ONCE_REWRITE_TAC[SET_RULE
         `{x | P x /\ Q x} = {x | x IN {y | P y} /\ Q x}`] THEN
        SIMP_TAC[FINITE_RESTRICT; FINITE_NUMSEG_LT];
        ONCE_REWRITE_TAC[COPRIME_SYM] THEN REWRITE_TAC[PHI_ALT] THEN
        AP_TERM_TAC THEN SET_TAC[];
        ASM_REWRITE_TAC[SUBSET; FORALL_IN_IMAGE; IN_ELIM_THM; MOD_LT_EQ] THEN
        ASM_REWRITE_TAC[COPRIME_REXP; COPRIME_RMOD]];
      DISCH_THEN(MP_TAC o snd o EQ_IMP_RULE) THEN ANTS_TAC THENL
       [REWRITE_TAC[GSYM CONG] THEN ASM_SIMP_TAC[ORDER_DIVIDES_EXPDIFF] THEN
        REWRITE_TAC[CONG_IMP_EQ];
        DISCH_THEN(MP_TAC o SPEC `a MOD n`) THEN
        ASM_REWRITE_TAC[MOD_LT_EQ; COPRIME_RMOD; CONG]]];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `!d:num. (g EXP (d * k) == a) (mod n) <=>
            (g EXP (d * k) == g EXP r) (mod n)`
   (fun th -> REWRITE_TAC[th])
  THENL
   [ASM_MESON_TAC[CONG_SYM; CONG_REFL; CONG_TRANS];
    ASM_SIMP_TAC[ORDER_DIVIDES_EXPDIFF]] THEN
  SUBGOAL_THEN
   `!i:num. (a EXP i == 1) (mod n) <=> (g EXP (r * i) == 1) (mod n)`
   (fun th -> REWRITE_TAC[th])
  THENL
   [X_GEN_TAC `i:num` THEN REWRITE_TAC[GSYM EXP_EXP; CONG] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[CONG]) THEN ASM_MESON_TAC[MOD_EXP_MOD];
    ALL_TAC] THEN
  ONCE_REWRITE_TAC[MULT_SYM] THEN
  REWRITE_TAC[HAS_SIZE; REWRITE_RULE[HAS_SIZE] COUNT_CONG_SOLVE] THEN
  ASM_REWRITE_TAC[PHI_EQ_0; ORDER_DIVIDES] THEN
  MP_TAC(NUMBER_RULE `gcd(k,phi(n)) divides phi(n)`) THEN
  GEN_REWRITE_TAC LAND_CONV [divides] THEN
  ABBREV_TAC `d = gcd(k,phi n)` THEN DISCH_THEN(X_CHOOSE_THEN `p:num`
   (fun th -> ASSUME_TAC(SYM th) THEN SUBST1_TAC th)) THEN
  ASM_CASES_TAC `d = 0` THENL [ASM_MESON_TAC[GCD_ZERO; PHI_EQ_0]; ALL_TAC] THEN
  ASM_SIMP_TAC[DIV_MULT] THEN ONCE_REWRITE_TAC[MULT_SYM] THEN
  SUBST1_TAC(SYM(ASSUME `d * p = phi n`)) THEN
  ASM_CASES_TAC `p = 0` THENL
   [ASM_MESON_TAC[MULT_CLAUSES; PHI_EQ_0]; ALL_TAC] THEN
  ASM_SIMP_TAC[DIVIDES_RMUL2_EQ] THEN
  ASM_MESON_TAC[NUMBER_RULE `gcd(k,n) = d /\ d * p = n ==> gcd(n,k) = d`]);;

let COUNT_ROOTS_MODULO_PRIMITIVE_GEN = prove
 (`!n a k.
        ~(n = 0) /\ ~(k = 0) /\ coprime(n,a) /\ (?x. order n x = phi n)
        ==> {x | x < n /\ (x EXP k == a) (mod n)} HAS_SIZE
            (if (a EXP (phi n DIV gcd(k,phi n)) == 1) (mod n)
             then gcd(k,phi n) else 0)`,
  REPEAT GEN_TAC THEN DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  MP_TAC(SPECL [`n:num`; `a:num`; `k:num`]
        COUNT_ROOTS_MODULO_PRIMITIVE_GEN_ALT) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC EQ_IMP THEN
  AP_THM_TAC THEN AP_TERM_TAC THEN
  GEN_REWRITE_TAC I [EXTENSION] THEN REWRITE_TAC[IN_ELIM_THM] THEN
  GEN_TAC THEN EQ_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP CONG_COPRIME) THEN
  ASM_REWRITE_TAC[COPRIME_REXP]);;

let POWER_RESIDUE_MODULO_PRIMITIVE = prove
 (`!n a k.
        coprime(n,a) /\ (?x. order n x = phi n)
        ==> ((?x. (x EXP k == a) (mod n)) <=>
             (a EXP (phi n DIV gcd(k,phi n)) == 1) (mod n))`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [ASM_REWRITE_TAC[COPRIME_0] THEN DISCH_THEN(SUBST1_TAC o CONJUNCT1) THEN
    REWRITE_TAC[EXP_ONE; CONG_MOD_0] THEN MESON_TAC[EXP_ONE];
    DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC)] THEN
  ASM_CASES_TAC `k = 0` THENL
   [ASM_SIMP_TAC[GCD_0; DIV_REFL; PHI_EQ_0; EXP_1; EXP] THEN
    REWRITE_TAC[CONG_SYM];
    ALL_TAC] THEN
  MP_TAC(SPECL [`n:num`; `a:num`; `k:num`]
        COUNT_ROOTS_MODULO_PRIMITIVE_GEN) THEN
  ASM_REWRITE_TAC[] THEN COND_CASES_TAC THEN ASM_REWRITE_TAC[] THENL
   [GEN_REWRITE_TAC I [GSYM CONTRAPOS_THM] THEN
    REWRITE_TAC[NOT_EXISTS_THM] THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[HAS_SIZE; EMPTY_GSPEC; CARD_CLAUSES; FINITE_EMPTY] THEN
    ASM_MESON_TAC[GCD_ZERO; PHI_EQ_0];
    REWRITE_TAC[HAS_SIZE_0; EXTENSION; IN_ELIM_THM; NOT_IN_EMPTY] THEN
    REWRITE_TAC[GSYM NOT_EXISTS_THM; CONTRAPOS_THM] THEN
    DISCH_THEN(X_CHOOSE_TAC `x:num`) THEN EXISTS_TAC `x MOD n` THEN
    ASM_REWRITE_TAC[MOD_LT_EQ] THEN REWRITE_TAC[CONG] THEN
    REWRITE_TAC[MOD_EXP_MOD] THEN ASM_REWRITE_TAC[GSYM CONG]]);;

let POWER_RESIDUE_MODULO_PRIME_EQ = prove
 (`!p a k.
        prime p /\ ~(p divides a)
        ==> ((?x. (x EXP k == a) (mod p)) <=>
             (a EXP ((p - 1) DIV gcd(k,p - 1)) == 1) (mod p))`,
  REPEAT STRIP_TAC THEN
  MP_TAC(SPECL [`p:num`; `a:num`; `k:num`] POWER_RESIDUE_MODULO_PRIMITIVE) THEN
  ASM_SIMP_TAC[PHI_PRIME; PRIME_COPRIME_EQ] THEN
  ASM_MESON_TAC[PRIMITIVE_ROOT_MODULO_PRIME]);;

let POWER_RESIDUE_MODULO_PRIMITIVE_ORDER_ALT = prove
 (`!n a k.
        coprime(n,a) /\ (?x. order n x = phi n)
        ==> ((?x. (x EXP k == a) (mod n)) <=>
             order n a divides phi n DIV gcd (k,phi n))`,
  SIMP_TAC[POWER_RESIDUE_MODULO_PRIMITIVE; ORDER_DIVIDES]);;

let POWER_RESIDUE_MODULO_PRIMITIVE_ORDER = prove
 (`!n a k.
        coprime(n,a) /\ (?x. order n x = phi n)
        ==> ((?x. (x EXP k == a) (mod n)) <=>
             gcd(k,phi n) divides phi n DIV order n a)`,
  ASM_SIMP_TAC[POWER_RESIDUE_MODULO_PRIMITIVE_ORDER_ALT] THEN
  SIMP_TAC[DIVIDES_DIVIDES_DIV; GCD; ORDER_DIVIDES_PHI] THEN
  REWRITE_TAC[MULT_SYM]);;

let QUADRATIC_RESIDUE_MODULO_PRIMITIVE_ORDER = prove
 (`!n a. coprime(n,a) /\ 3 <= n /\ (?x. order n x = phi n)
         ==> ((?x. (x EXP 2 == a) (mod n)) <=> EVEN(phi n DIV order n a))`,
  REPEAT GEN_TAC THEN
  SIMP_TAC[POWER_RESIDUE_MODULO_PRIMITIVE_ORDER] THEN
  SIMP_TAC[GSYM DIVIDES_2; REWRITE_RULE[GSYM DIVIDES_2] EVEN_PHI;
           NUMBER_RULE `(a:num) divides b ==> gcd(a,b) = a`]);;

let POWER_RESIDUE_MODULO_PRIMITIVE_POWER = prove
 (`!n g m k.
        coprime(n,g) /\ order n g = phi n
        ==> ((?x. (x EXP k == g EXP m) (mod n)) <=> gcd(k,phi n) divides m)`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [ASM_MESON_TAC[PHI_EQ_0; ORDER_EQ_0]; ALL_TAC] THEN
  W(MP_TAC o PART_MATCH (lhand o rand) POWER_RESIDUE_MODULO_PRIMITIVE_ORDER o
        lhand o snd) THEN
  ANTS_TAC THENL [ASM_MESON_TAC[COPRIME_REXP]; DISCH_THEN SUBST1_TAC] THEN
  ASM_REWRITE_TAC[ORDER_EXP_GEN] THEN
  COND_CASES_TAC THEN ASM_REWRITE_TAC[GCD; DIV_1; DIVIDES_0] THEN
  ASM_SIMP_TAC[DIV_BY_DIV; PHI_EQ_0; GCD] THEN CONV_TAC NUMBER_RULE);;

let QUADRATIC_RESIDUE_MODULO_PRIMITIVE_POWER = prove
 (`!n g m.
        coprime(n,g) /\ order n g = phi n
        ==> ((?x. (x EXP 2 == g EXP m) (mod n)) <=>
             3 <= n ==> EVEN m)`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [ASM_MESON_TAC[PHI_EQ_0; ORDER_EQ_0]; ALL_TAC] THEN
  ASM_SIMP_TAC[POWER_RESIDUE_MODULO_PRIMITIVE_POWER] THEN
  ASM_REWRITE_TAC[GCD_2_CASES; EVEN_PHI_EQ] THEN
  ASM_CASES_TAC `3 <= n` THEN ASM_REWRITE_TAC[DIVIDES_1; DIVIDES_2]);;

let COUNT_POWER_RESIDUES_MODULO_PRIMITIVE = prove
 (`!n k. ~(n = 0) /\ (?g. order n g = phi n)
         ==> {a | a < n /\ coprime(n,a) /\ ?x. (x EXP k == a) (mod n)}
             HAS_SIZE phi n DIV gcd(k,phi n)`,
  REPEAT GEN_TAC THEN DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  ONCE_REWRITE_TAC[SET_RULE
   `{x | P x /\ Q x /\ R x} = {x | ~(P x /\ Q x ==> ~R x)}`] THEN
  ASM_SIMP_TAC[POWER_RESIDUE_MODULO_PRIMITIVE] THEN
  ASM_SIMP_TAC[NOT_IMP; GSYM CONJ_ASSOC; HAS_SIZE;
   REWRITE_RULE[HAS_SIZE] COUNT_ROOTS_MODULO_PRIMITIVE_GEN_ALT] THEN
  REWRITE_TAC[EXP_ONE; CONG_REFL; GSYM DIVIDES_GCD_LEFT] THEN
  SIMP_TAC[DIVIDES_DIV_SELF; GCD]);;

let COUNT_QUADRATIC_RESIDUES_MODULO_PRIMITIVE = prove
 (`!n. 3 <= n /\ (?g. order n g = phi n)
       ==> {a | a < n /\ coprime(n,a) /\ ?x. (x EXP 2 == a) (mod n)}
           HAS_SIZE phi n DIV 2`,
  GEN_TAC THEN DISCH_TAC THEN
  MP_TAC(SPECL [`n:num`; `2`] COUNT_POWER_RESIDUES_MODULO_PRIMITIVE) THEN
  ASM_SIMP_TAC[GCD_2_CASES; EVEN_PHI_EQ] THEN
  DISCH_THEN MATCH_MP_TAC THEN ASM_ARITH_TAC);;

let INT_OF_NUM_POWER_RESIDUE = prove
 (`!n k a. (?x:num. (x EXP k == a) (mod n)) <=>
           (?x:int. (x pow k == &a) (mod &n))`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `n = 0` THENL
   [ASM_REWRITE_TAC[CONG_MOD_0; INT_CONG_MOD_0] THEN
    REWRITE_TAC[EXISTS_INT_CASES; INT_POW_NEG] THEN
    ASM_CASES_TAC `EVEN k` THEN
    ASM_REWRITE_TAC[INT_OF_NUM_POW; INT_OF_NUM_EQ; INT_ARITH
     `--(&m):int = &n <=> &m:int = &n /\ &n:int = &0`] THEN
    MESON_TAC[];
    REWRITE_TAC[num_congruent; GSYM INT_OF_NUM_POW]] THEN
  EQ_TAC THENL [MESON_TAC[]; ALL_TAC] THEN
  DISCH_THEN(X_CHOOSE_TAC `x:int`) THEN
  MP_TAC(ISPECL [`x:int`; `&n:int`] INT_CONG_NUM_EXISTS) THEN
  ASM_REWRITE_TAC[INT_OF_NUM_EQ] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `m:num` THEN DISCH_TAC THEN
  MATCH_MP_TAC INT_CONG_TRANS THEN EXISTS_TAC `(x:int) pow k` THEN
  ASM_SIMP_TAC[INT_CONG_POW]);;

let QUADRATIC_RESIDUE_MODULO_ODD_POWER = prove
 (`!n a k.
        ODD n /\ coprime(n,a)
        ==> ((?x. (x EXP 2 == a) (mod (n EXP k))) <=>
             k = 0 \/ ?x. (x EXP 2 == a) (mod n))`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `k = 0` THEN
  ASM_REWRITE_TAC[EXP; CONG_MOD_1] THEN EQ_TAC THENL
   [MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `x:num` THEN
    MATCH_MP_TAC(NUMBER_RULE
     `p EXP 1 divides q ==> (x == a) (mod q) ==> (x == a) (mod p)`) THEN
    MATCH_MP_TAC DIVIDES_EXP_LE_IMP THEN ASM_ARITH_TAC;
    DISCH_TAC THEN UNDISCH_TAC `~(k = 0)` THEN SPEC_TAC(`k:num`,`k:num`)] THEN
  MATCH_MP_TAC num_INDUCTION THEN REWRITE_TAC[] THEN
  X_GEN_TAC `k:num` THEN ASM_CASES_TAC `k = 0` THEN
  ASM_REWRITE_TAC[EXP; MULT_CLAUSES; NOT_SUC] THEN
  FIRST_X_ASSUM(K ALL_TAC o check (is_exists o concl)) THEN
  REWRITE_TAC[INT_OF_NUM_POWER_RESIDUE] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_MUL; GSYM INT_OF_NUM_POW] THEN
  DISCH_THEN(X_CHOOSE_THEN `x:int` (MP_TAC o REWRITE_RULE[int_congruent])) THEN
  DISCH_THEN(X_CHOOSE_TAC `z:int`) THEN
  MP_TAC(ISPECL [`&2 * x:int`; `--z:int`; `&n:int`]
        INT_CONG_SOLVE) THEN
  ANTS_TAC THENL
   [ASM_REWRITE_TAC[INT_COPRIME_LMUL; GSYM num_coprime; COPRIME_2] THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (INTEGER_RULE
     `x pow 2 - a = nk * z
      ==> coprime(n,a) /\ n pow 1 divides nk ==> coprime(x,n)`)) THEN
    ASM_REWRITE_TAC[GSYM num_coprime] THEN
    MATCH_MP_TAC INT_DIVIDES_POW_LE_IMP THEN ASM_ARITH_TAC;
    DISCH_THEN(X_CHOOSE_TAC `y:int`) THEN
    EXISTS_TAC `(x:int) + y * &n pow k` THEN MATCH_MP_TAC(INTEGER_RULE
     `x pow 2 - a = m * z /\
      ((&2 * x) * y:int == --z) (mod n) /\
      n pow 1 divides m
      ==> ((x + y * m) pow 2 == a) (mod (n * m))`) THEN
    ASM_REWRITE_TAC[] THEN MATCH_MP_TAC INT_DIVIDES_POW_LE_IMP THEN
    ASM_ARITH_TAC]);;

let QUADRATIC_RESIDUE_MODULO_POWER_2_STABLE = prove
 (`!a k. ODD a /\ 3 <= k
         ==> ((?x. (x EXP 2 == a) (mod (2 EXP k))) <=>
              (?x. (x EXP 2 == a) (mod 8)))`,
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN GEN_TAC THEN DISCH_TAC THEN
  REWRITE_TAC[FORALL_AND_THM; ARITH_RULE `8 = 2 EXP 3`; TAUT
   `p ==> (q <=> r) <=> (p ==> q ==> r) /\ (r ==> p ==> q)`] THEN
  CONJ_TAC THENL
   [GEN_TAC THEN DISCH_TAC THEN MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC THEN
    MATCH_MP_TAC(NUMBER_RULE
     `(m:num) divides n ==> (a == b) (mod n) ==> (a == b) (mod m)`) THEN
    MATCH_MP_TAC DIVIDES_EXP_LE_IMP THEN ASM_REWRITE_TAC[];
    REWRITE_TAC[RIGHT_FORALL_IMP_THM] THEN DISCH_TAC] THEN
  MATCH_MP_TAC num_INDUCTION THEN CONV_TAC NUM_REDUCE_CONV THEN
  X_GEN_TAC `k:num` THEN
  REWRITE_TAC[ARITH_RULE `3 <= SUC k <=> SUC k = 3 \/ 3 <= k`] THEN
  ASM_CASES_TAC `SUC k = 3` THEN ASM_REWRITE_TAC[] THEN
  UNDISCH_TAC `ODD a` THEN POP_ASSUM_LIST(K ALL_TAC) THEN
  ASM_CASES_TAC `3 <= k` THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[INT_OF_NUM_POWER_RESIDUE; GSYM INT_OF_NUM_POW] THEN
  REWRITE_TAC[GSYM NOT_EVEN; GSYM DIVIDES_2; num_divides] THEN
  DISCH_TAC THEN DISCH_THEN(X_CHOOSE_TAC `x:int`) THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [int_congruent]) THEN
  REWRITE_TAC[INT_ARITH `a - b:int = c <=> a = b + c`] THEN
  DISCH_THEN(X_CHOOSE_TAC `b:int`) THEN
  FIRST_ASSUM(MP_TAC o AP_TERM `\x:int. &2 divides x`) THEN
  ASM_REWRITE_TAC[INT_2_DIVIDES_POW; INT_2_DIVIDES_ADD; INT_2_DIVIDES_MUL] THEN
  ASM_SIMP_TAC[INT_DIVIDES_REFL; ARITH_RULE `3 <= k ==> ~(k = 0)`] THEN
  CONV_TAC NUM_REDUCE_CONV THEN DISCH_TAC THEN
  EXISTS_TAC `(x:int) + b * &2 pow (k - 1)` THEN
  REWRITE_TAC[INT_ARITH
   `(x + y:int) pow 2 = x pow 2 + y pow 2 + &2 * x * y`] THEN
  ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[INTEGER_RULE
   `((a + b) + (d + &2 * x * c * p):int == a) (mod n) <=>
    n divides (d + b + x * c * &2 * p)`] THEN
  REWRITE_TAC[INT_POW_MUL; INT_POW_POW; ADD1] THEN
  MATCH_MP_TAC INT_DIVIDES_ADD THEN CONJ_TAC THENL
   [MATCH_MP_TAC INT_DIVIDES_LMUL THEN MATCH_MP_TAC INT_DIVIDES_POW_LE_IMP THEN
    ASM_ARITH_TAC;
    REWRITE_TAC[GSYM(CONJUNCT2 INT_POW)]] THEN
  ASM_SIMP_TAC[ARITH_RULE `3 <= k ==> SUC(k - 1) = k`] THEN
  REWRITE_TAC[INT_POW_ADD; INT_POW_1] THEN MATCH_MP_TAC(INTEGER_RULE
   `t divides (c * x + b:int) ==> k * t divides k * b + x * c * k`) THEN
  ASM_REWRITE_TAC[INT_2_DIVIDES_ADD; INT_2_DIVIDES_MUL]);;

let QUADRATIC_RESIDUE_MODULO_POWER_2 = prove
 (`!a k. ODD a /\ 3 <= k
         ==> ((?x. (x EXP 2 == a) (mod (2 EXP k))) <=> (a == 1) (mod 8))`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[QUADRATIC_RESIDUE_MODULO_POWER_2_STABLE] THEN
  EQ_TAC THENL [ALL_TAC; MESON_TAC[EXP_ONE; CONG_SYM]] THEN
  DISCH_THEN(X_CHOOSE_THEN `n:num` MP_TAC) THEN REWRITE_TAC[CONG] THEN
  ONCE_REWRITE_TAC[GSYM MOD_EXP_MOD] THEN
  SUBGOAL_THEN `ODD(a MOD 8)` MP_TAC THENL
   [ASM_SIMP_TAC[ODD_MOD_EVEN; ARITH]; ALL_TAC] THEN
  MP_TAC(ARITH_RULE `n MOD 8 < 8`) THEN SPEC_TAC(`n MOD 8`,`n:num`) THEN
  MP_TAC(ARITH_RULE `a MOD 8 < 8`) THEN SPEC_TAC(`a MOD 8`,`a:num`) THEN
  CONV_TAC EXPAND_CASES_CONV THEN CONV_TAC NUM_REDUCE_CONV THEN
  REPEAT CONJ_TAC THEN
  CONV_TAC EXPAND_CASES_CONV THEN CONV_TAC NUM_REDUCE_CONV);;

let GENERALIZED_EULER_CRITERION = prove
 (`!n a k.
        (n = 0 \/ n = 1 \/ n = 2 \/ n = 4 \/
         ?p k. prime p /\ 3 <= p /\ (n = p EXP k \/ n = 2 * p EXP k)) /\
        coprime(n,a)
        ==> ((?x. (x EXP k == a) (mod n)) <=>
             (a EXP (phi n DIV gcd(k,phi n)) == 1) (mod n))`,
  REPEAT GEN_TAC THEN
  ASM_CASES_TAC `n = 1` THEN ASM_REWRITE_TAC[CONG_MOD_1] THEN
  ASM_CASES_TAC `n = 0` THENL
   [ASM_REWRITE_TAC[CONG_MOD_0; PHI_0; DIV_0; COPRIME_0; EXP] THEN
    MESON_TAC[EXP_ONE];
    DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
    MATCH_MP_TAC POWER_RESIDUE_MODULO_PRIMITIVE THEN
    ASM_REWRITE_TAC[PRIMITIVE_ROOT_EXISTS]]);;

let GENERALIZED_EULER_CRITERION_PRIME = prove
 (`!p a k.
        prime p
        ==> ((?x. (x EXP k == a) (mod p)) <=>
             if p divides a then ~(k = 0)
             else (a EXP ((p - 1) DIV gcd(k,p-1)) == 1) (mod p))`,
  REPEAT STRIP_TAC THEN COND_CASES_TAC THENL
   [ASM_CASES_TAC `k = 0` THEN ASM_REWRITE_TAC[EXP] THENL
     [DISCH_THEN(MP_TAC o MATCH_MP (NUMBER_RULE
       `(1 == a) (mod p) ==> p divides a ==> p = 1`)) THEN
      ASM_MESON_TAC[PRIME_1];
      EXISTS_TAC `0` THEN ASM_SIMP_TAC[NUMBER_RULE
       `p divides a ==> ((x:num == a) (mod p) <=> p divides x)`] THEN
      ASM_SIMP_TAC[PRIME_DIVEXP_EQ; DIVIDES_0]];
    MP_TAC(SPECL [`p:num`; `a:num`; `k:num`] GENERALIZED_EULER_CRITERION) THEN
    ASM_SIMP_TAC[PHI_PRIME] THEN DISCH_THEN MATCH_MP_TAC THEN
    ASM_SIMP_TAC[PRIME_COPRIME_EQ] THEN
    ASM_CASES_TAC `p = 2` THEN ASM_REWRITE_TAC[] THEN
    REPEAT DISJ2_TAC THEN MAP_EVERY EXISTS_TAC [`p:num`; `1`] THEN
    ASM_SIMP_TAC[EXP_1] THEN FIRST_X_ASSUM(MP_TAC o MATCH_MP PRIME_GE_2) THEN
    ASM_ARITH_TAC]);;

let EULER_CRITERION = prove
 (`!p a. prime p
         ==> ((?x. (x EXP 2 == a) (mod p)) <=>
              p divides a \/ (a EXP ((p - 1) DIV 2) == 1) (mod p))`,
  REPEAT STRIP_TAC THEN
  MP_TAC(SPECL [`p:num`; `a:num`; `2`] GENERALIZED_EULER_CRITERION_PRIME) THEN
  ASM_CASES_TAC `(p:num) divides a` THEN ASM_REWRITE_TAC[ARITH_EQ] THEN
  DISCH_THEN SUBST1_TAC THEN ASM_CASES_TAC `p = 2` THENL
   [UNDISCH_TAC `~((p:num) divides a)` THEN
    ASM_REWRITE_TAC[DIVIDES_2] THEN CONV_TAC NUM_REDUCE_CONV THEN
    SIMP_TAC[GCD_1; DIV_REFL; ARITH_EQ; EXP_1; GSYM ODD_MOD_2] THEN
    REWRITE_TAC[NOT_EVEN; EXP; ARITH];
    SUBGOAL_THEN `gcd(2,p - 1) = 2` (fun th -> REWRITE_TAC[th]) THEN
    REWRITE_TAC[GSYM DIVIDES_GCD_LEFT; DIVIDES_2; EVEN_SUB] THEN
    DISJ2_TAC THEN REWRITE_TAC[ARITH; NOT_EVEN] THEN
    ASM_MESON_TAC[PRIME_ODD]]);;

let COUNT_ROOTS_MODULO_ODD_GEN = prove
 (`!n a k.
        ODD n /\ coprime(n,a) /\ ~(k = 0)
        ==> {x | x < n /\ (x EXP k == a) (mod n)} HAS_SIZE
            (if !p. prime p /\ p divides n
                    ==> (a EXP ((p EXP (index p n - 1) * (p - 1)) DIV
                                gcd(k,p EXP (index p n - 1) * (p - 1))) == 1)
                        (mod (p EXP index p n))
             then nproduct {p | prime p /\ p divides n}
                           (\p. gcd(k,p EXP (index p n - 1) * (p - 1)))
             else 0)`,
  MAP_EVERY X_GEN_TAC [`n:num`; `z:num`; `k:num`] THEN
  REWRITE_TAC[nproduct] THEN ASM_CASES_TAC `k = 0` THEN ASM_REWRITE_TAC[] THEN
  ASM_CASES_TAC `n = 0` THEN ASM_REWRITE_TAC[ODD] THEN
  ASM_CASES_TAC `n = 1` THENL
   [ASM_REWRITE_TAC[MESON[PRIME_1; DIVIDES_ONE]
      `~(prime p /\ p divides 1)`] THEN
    ASM_REWRITE_TAC[EMPTY_GSPEC; MATCH_MP ITERATE_CLAUSES MONOIDAL_MUL] THEN
    REWRITE_TAC[CONG_MOD_1; NEUTRAL_MUL; HAS_SIZE_NUMSEG_LT];
    MAP_EVERY UNDISCH_TAC [`~(n = 1)`; `~(n = 0)`]] THEN
  GEN_REWRITE_TAC I [IMP_IMP] THEN
  REWRITE_TAC[ARITH_RULE `~(n = 0) /\ ~(n = 1) <=> 1 < n`] THEN
  SPEC_TAC(`n:num`,`n:num`) THEN
  MATCH_MP_TAC INDUCT_COPRIME_STRONG THEN CONJ_TAC THENL
   [MAP_EVERY X_GEN_TAC [`a:num`; `b:num`] THEN REWRITE_TAC[ODD_MULT] THEN
    ASM_CASES_TAC `ODD a` THEN ASM_REWRITE_TAC[] THEN
    ASM_CASES_TAC `ODD b` THEN ASM_REWRITE_TAC[IMP_IMP] THEN
    REWRITE_TAC[COPRIME_LMUL] THEN
    ASM_CASES_TAC `coprime(a:num,z)` THEN ASM_REWRITE_TAC[] THEN
    ASM_CASES_TAC `coprime(b:num,z)` THEN ASM_REWRITE_TAC[] THEN
    STRIP_TAC THEN REWRITE_TAC[MESON[PRIME_DIVPROD_EQ]
     `prime p /\ p divides a * b <=>
      prime p /\ (p divides a \/ p divides b)`] THEN
    REWRITE_TAC[SET_RULE
     `{x | P x /\ (Q x \/ R x)} =
      {x | P x /\ Q x} UNION {x | P x /\ R x}`] THEN
    W(MP_TAC o PART_MATCH (lhand o rand)
     (MATCH_MP ITERATE_UNION MONOIDAL_MUL) o lhand o rand o snd) THEN
    ANTS_TAC THENL
     [REWRITE_TAC[CONJ_ASSOC] THEN CONJ_TAC THENL
       [CONJ_TAC THEN MATCH_MP_TAC(MESON[FINITE_SUBSET]
         `FINITE {d | d divides a} /\
          {p | prime p /\ p divides a} SUBSET {d | d divides a}
          ==> FINITE {p | prime p /\ p divides a}`) THEN
        ASM_SIMP_TAC[FINITE_DIVISORS; ARITH_RULE `1 < n ==> ~(n = 0)`] THEN
        SET_TAC[];
        REWRITE_TAC[SET_RULE `DISJOINT s t <=> !x. ~(x IN s /\ x IN t)`] THEN
        REWRITE_TAC[IN_ELIM_THM] THEN ASM_MESON_TAC[COPRIME_PRIME]];
      DISCH_THEN SUBST1_TAC] THEN
    REWRITE_TAC[MESON[]
     `(!p. prime p /\ (P p \/ Q p) ==> R p) <=>
      (!p. prime p /\ P p ==> R p) /\ (!p. prime p /\ Q p ==> R p)`] THEN
    REWRITE_TAC[MESON[MULT_CLAUSES]
     `(if p /\ q then a * b else 0) =
      (if p then a else 0) * (if q then b else 0)`] THEN
    MATCH_MP_TAC CHINESE_REMAINDER_COUNT THEN
    EXISTS_TAC `\x. (x EXP k == z) (mod a)` THEN
    EXISTS_TAC `\x. (x EXP k == z) (mod b)` THEN
    ASM_SIMP_TAC[NUMBER_RULE
       `coprime(a,b)
           ==> ((x == y) (mod (a * b)) <=>
                (x == y) (mod a) /\ (x == y) (mod b))`] THEN
    CONJ_TAC THENL [REWRITE_TAC[CONG; MOD_EXP_MOD]; ALL_TAC] THEN
    SUBGOAL_THEN
     `(!p. prime p /\ p divides a ==> index p (a * b) = index p a) /\
      (!p. prime p /\ p divides b ==> index p (a * b) = index p b)`
    STRIP_ASSUME_TAC THENL
     [ASM_SIMP_TAC[INDEX_MUL; ARITH_RULE `1 < n ==> ~(n = 0)`] THEN
      REWRITE_TAC[EQ_ADD_LCANCEL_0; EQ_ADD_RCANCEL_0] THEN
      REWRITE_TAC[INDEX_EQ_0] THEN ASM_MESON_TAC[COPRIME_PRIME_EQ];
      ASM_SIMP_TAC[]] THEN
    CONJ_TAC THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (MESON[]
     `s HAS_SIZE m ==> n = m ==> s HAS_SIZE n`)) THEN
    COND_CASES_TAC THEN ASM_REWRITE_TAC[] THEN
    MATCH_MP_TAC(MATCH_MP ITERATE_EQ MONOIDAL_MUL) THEN
    ASM_SIMP_TAC[IN_ELIM_THM];
    MAP_EVERY X_GEN_TAC [`p:num`; `j:num`] THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[ODD_EXP; COPRIME_LEXP] THEN STRIP_TAC THEN
    ASM_SIMP_TAC[MESON[PRIME_DIVEXP_EQ; DIVIDES_PRIME_PRIME]
     `~(n = 0) /\ prime p ==> (prime q /\ q divides p EXP n <=> q = p)`] THEN
    REWRITE_TAC[FORALL_UNWIND_THM2] THEN
    REWRITE_TAC[SING_GSPEC; MATCH_MP ITERATE_SING MONOIDAL_MUL] THEN
    W(MP_TAC o PART_MATCH (lhand o rand) COUNT_ROOTS_MODULO_PRIMITIVE_GEN o
        lhand o snd) THEN
    ASM_REWRITE_TAC[EXP_EQ_0] THEN ANTS_TAC THENL
     [CONJ_TAC THENL [ASM_MESON_TAC[PRIME_0]; ALL_TAC] THEN
      ASM_REWRITE_TAC[COPRIME_LEXP] THEN
      ASM_REWRITE_TAC[PRIMITIVE_ROOT_EXISTS] THEN ASM_MESON_TAC[ODD_PRIME];
      FIRST_ASSUM(ASSUME_TAC o MATCH_MP PRIME_GE_2) THEN
      ASM_SIMP_TAC[PHI_PRIMEPOW_ALT; INDEX_EXP; INDEX_REFL] THEN
      ASM_SIMP_TAC[ARITH_RULE `2 <= p ==> ~(p <= 1)`; MULT_CLAUSES]]]);;

let COUNT_ROOTS_MODULO_ODD_ALT_GEN = prove
 (`!n a k.
        ODD n /\ ~(k = 0)
        ==> {x | x < n /\ coprime(n,x) /\ (x EXP k == a) (mod n)} HAS_SIZE
            (if !p. prime p /\ p divides n
                    ==> (a EXP ((p EXP (index p n - 1) * (p - 1)) DIV
                                gcd(k,p EXP (index p n - 1) * (p - 1))) == 1)
                        (mod (p EXP index p n))
             then nproduct {p | prime p /\ p divides n}
                           (\p. gcd(k,p EXP (index p n - 1) * (p - 1)))
             else 0)`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `coprime(n:num,a)` THENL
   [MP_TAC(SPECL [`n:num`; `a:num`; `k:num`]
        COUNT_ROOTS_MODULO_ODD_GEN) THEN
    ASM_REWRITE_TAC[] THEN MATCH_MP_TAC EQ_IMP THEN
    AP_THM_TAC THEN AP_TERM_TAC THEN
    REWRITE_TAC[EXTENSION; IN_ELIM_THM] THEN
    X_GEN_TAC `i:num` THEN EQ_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    FIRST_X_ASSUM(MP_TAC o MATCH_MP CONG_COPRIME) THEN
    ASM_REWRITE_TAC[COPRIME_REXP];
    MATCH_MP_TAC(MESON[HAS_SIZE_0]
     `s = {} /\ ~p ==> s HAS_SIZE (if p then n else 0)`) THEN
    CONJ_TAC THENL
     [REWRITE_TAC[EXTENSION; IN_ELIM_THM; NOT_IN_EMPTY] THEN
      REPEAT STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o MATCH_MP CONG_COPRIME) THEN
      ASM_REWRITE_TAC[COPRIME_REXP];
      FIRST_X_ASSUM(MP_TAC o
        GEN_REWRITE_RULE RAND_CONV [COPRIME_PRIME_EQ]) THEN
      REWRITE_TAC[NOT_FORALL_THM] THEN MATCH_MP_TAC MONO_EXISTS THEN
      X_GEN_TAC `p:num` THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
      DISCH_THEN(MP_TAC o SPEC `p:num` o MATCH_MP (NUMBER_RULE
       `!p. (a == 1) (mod n)
            ==> p divides a /\ p divides n ==> p divides 1`)) THEN
      ASM_SIMP_TAC[NOT_IMP; DIVIDES_ONE; PRIME_DIVEXP_EQ] THEN
      ASM_REWRITE_TAC[DIVIDES_REFL; INDEX_EQ_0] THEN
      ASM_SIMP_TAC[MESON[PRIME_1] `prime p ==> ~(p = 1)`] THEN
      CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[ODD]] THEN
      ASM_SIMP_TAC[DIV_EQ_0; GCD_ZERO] THEN
      ASM_REWRITE_TAC[GSYM NOT_LE; GCD_LE] THEN
      ASM_REWRITE_TAC[EXP_EQ_0; MULT_EQ_0] THEN
      FIRST_X_ASSUM(MP_TAC o MATCH_MP PRIME_GE_2) THEN ARITH_TAC]]);;

let POWER_RESIDUE_MODULO_ODD = prove
 (`!n a k.
        ODD n /\ ~(k = 0) /\ coprime(n,a)
        ==> ((?x. (x EXP k == a) (mod n)) <=>
             !p. prime p /\ p divides n
                 ==> (a EXP ((p EXP (index p n - 1) * (p - 1)) DIV
                              gcd(k,p EXP (index p n - 1) * (p - 1))) == 1)
                     (mod (p EXP index p n)))`,
  REPEAT STRIP_TAC THEN
  MP_TAC(SPECL [`n:num`; `a:num`; `k:num`]
        COUNT_ROOTS_MODULO_ODD_GEN) THEN
  ASM_REWRITE_TAC[nproduct] THEN COND_CASES_TAC THEN ASM_REWRITE_TAC[] THENL
   [GEN_REWRITE_TAC I [GSYM CONTRAPOS_THM] THEN
    REWRITE_TAC[NOT_EXISTS_THM] THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[HAS_SIZE; EMPTY_GSPEC; CARD_CLAUSES; FINITE_EMPTY] THEN
    CONV_TAC(RAND_CONV SYM_CONV) THEN
    SUBGOAL_THEN `FINITE {p | prime p /\ p divides n}` MP_TAC THENL
     [MATCH_MP_TAC FINITE_SPECIAL_DIVISORS THEN ASM_MESON_TAC[ODD];
      SPEC_TAC(`{p | prime p /\ p divides n}`,`s:num->bool`)] THEN
    MATCH_MP_TAC FINITE_INDUCT_STRONG THEN
    SIMP_TAC[MATCH_MP ITERATE_CLAUSES MONOIDAL_MUL; NEUTRAL_MUL] THEN
    ASM_SIMP_TAC[MULT_EQ_0; GCD_ZERO] THEN ARITH_TAC;
    REWRITE_TAC[HAS_SIZE_0; EXTENSION; IN_ELIM_THM; NOT_IN_EMPTY] THEN
    REWRITE_TAC[GSYM NOT_EXISTS_THM; CONTRAPOS_THM] THEN
    DISCH_THEN(X_CHOOSE_TAC `x:num`) THEN EXISTS_TAC `x MOD n` THEN
    ASM_REWRITE_TAC[MOD_LT_EQ] THEN REWRITE_TAC[CONG] THEN
    REWRITE_TAC[MOD_EXP_MOD] THEN ASM_REWRITE_TAC[GSYM CONG] THEN
    ASM_MESON_TAC[ODD]]);;

let COUNT_ROOTS_MODULO_PRIMITIVE_ALT = prove
 (`!n k. ~(n = 0) /\ (?x. order n x = phi n)
         ==> { x | x < n /\ coprime(n,x) /\ (x EXP k == 1) (mod n)}
             HAS_SIZE gcd(k,phi n)`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  MP_TAC(SPECL [`n:num`; `1`; `k:num`]
   COUNT_ROOTS_MODULO_PRIMITIVE_GEN_ALT) THEN
  ASM_REWRITE_TAC[EXP_ONE; CONG_REFL] THEN
  ASM_CASES_TAC `k = 0` THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[GCD_0; EXP; CONG_REFL; HAS_SIZE] THEN CONJ_TAC THENL
   [ONCE_REWRITE_TAC[SET_RULE
     `{x | P x /\ Q x} = {x | x IN {y | P y} /\ Q x}`] THEN
    SIMP_TAC[FINITE_RESTRICT; FINITE_NUMSEG_LT];
    ONCE_REWRITE_TAC[COPRIME_SYM] THEN REWRITE_TAC[PHI_ALT] THEN
    AP_TERM_TAC THEN SET_TAC[]]);;

let COUNT_ROOTS_MODULO_PRIMITIVE = prove
 (`!n k. ~(n = 0) /\ ~(k = 0) /\ (?x. order n x = phi n)
         ==> { x | x < n /\ (x EXP k == 1) (mod n)} HAS_SIZE gcd(k,phi n)`,
  REPEAT GEN_TAC THEN DISCH_THEN(REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC) THEN
  MP_TAC(SPECL [`n:num`; `k:num`] COUNT_ROOTS_MODULO_PRIMITIVE_ALT) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC EQ_IMP THEN AP_THM_TAC THEN
  AP_TERM_TAC THEN REWRITE_TAC[EXTENSION; IN_ELIM_THM] THEN
  X_GEN_TAC `x:num` THEN EQ_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP (NUMBER_RULE
   `(x == 1) (mod n) ==> coprime(x,n)`)) THEN
  ASM_REWRITE_TAC[COPRIME_LEXP] THEN REWRITE_TAC[COPRIME_SYM]);;

let COUNT_ROOTS_MODULO_ODD_ALT = prove
 (`!n k. ODD n /\ ~(k = 0)
         ==> {x | x < n /\ coprime(n,x) /\ (x EXP k == 1) (mod n)} HAS_SIZE
             nproduct {p | prime p /\ p divides n}
                      (\p. gcd(k,p EXP (index p n - 1) * (p - 1)))`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`n:num`; `1`; `k:num`]
     COUNT_ROOTS_MODULO_ODD_ALT_GEN) THEN
  ASM_REWRITE_TAC[EXP_ONE; CONG_REFL; COPRIME_1]);;

let COUNT_ROOTS_MODULO_ODD = prove
 (`!n k. ODD n /\ ~(k = 0)
         ==> {x | x < n /\ (x EXP k == 1) (mod n)} HAS_SIZE
             nproduct {p | prime p /\ p divides n}
                      (\p. gcd(k,p EXP (index p n - 1) * (p - 1)))`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`n:num`; `1`; `k:num`] COUNT_ROOTS_MODULO_ODD_GEN) THEN
  ASM_REWRITE_TAC[EXP_ONE; CONG_REFL; COPRIME_1]);;

let POWER_RESIDUE_EXISTS = prove
 (`!n k. ~(n = 0) ==> ?a. a < n /\ coprime(n,a) /\ ?x. (x EXP k == a) (mod n)`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `n = 1` THENL
   [EXISTS_TAC `0` THEN ASM_REWRITE_TAC[COPRIME_1; CONG_MOD_1; ARITH];
    EXISTS_TAC `1` THEN REWRITE_TAC[COPRIME_1] THEN
    CONJ_TAC THENL [ASM_ARITH_TAC; EXISTS_TAC `1`] THEN
    REWRITE_TAC[EXP_ONE; CONG_REFL]]);;

let QUADRATIC_NONRESIDUE_EXISTS = prove
 (`!n. (?a. a < n /\ coprime(n,a) /\ ~(?x. (x EXP 2 == a) (mod n))) <=>
       3 <= n`,
  REWRITE_TAC[FORALL_AND_THM; TAUT
   `(p <=> q) <=> (~q ==> ~p) /\ (q ==> p)`] THEN
  CONJ_TAC THENL
   [REWRITE_TAC[ARITH_RULE `~(3 <= n) <=> n = 0 \/ n = 1 \/ n = 2`] THEN
    GEN_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[LT] THENL
     [REWRITE_TAC[ARITH_RULE `a < 1 <=> a = 0`; UNWIND_THM2] THEN
      REWRITE_TAC[COPRIME_1; CONG] THEN EXISTS_TAC `0` THEN
      CONV_TAC NUM_REDUCE_CONV;
      REWRITE_TAC[NOT_EXISTS_THM; TAUT `~(p /\ q) <=> p ==> ~q`] THEN
      CONV_TAC EXPAND_CASES_CONV THEN
      REWRITE_TAC[COPRIME_0; COPRIME_1; CONG; ARITH_EQ] THEN
      EXISTS_TAC `1`THEN
      CONV_TAC NUM_REDUCE_CONV];
    ALL_TAC] THEN
  MATCH_MP_TAC INDUCT_COPRIME_ALT THEN
  CONV_TAC NUM_REDUCE_CONV THEN CONJ_TAC THENL
   [MATCH_MP_TAC WLOG_LT THEN REPEAT CONJ_TAC THENL
     [REWRITE_TAC[COPRIME_REFL] THEN MESON_TAC[LT_REFL];
      REWRITE_TAC[MULT_SYM; COPRIME_SYM] THEN MESON_TAC[];
      MAP_EVERY X_GEN_TAC [`a:num`; `b:num`]] THEN
    DISCH_TAC THEN
    REPLICATE_TAC 3 (DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    DISCH_THEN(MP_TAC o CONJUNCT2) THEN
    ANTS_TAC THENL [ASM_ARITH_TAC; ALL_TAC] THEN
    DISCH_THEN(X_CHOOSE_THEN `t:num` STRIP_ASSUME_TAC) THEN DISCH_TAC THEN
    MP_TAC(SPECL[`a:num`; `b:num`; `1`; `t:num`] CHINESE_REMAINDER_UNIQUE) THEN
    ASM_REWRITE_TAC[] THEN ANTS_TAC THENL
     [ASM_ARITH_TAC; DISCH_THEN(MP_TAC o EXISTENCE)] THEN
    MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `u:num` THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[COPRIME_LMUL] THEN
    ASM_SIMP_TAC[NUMBER_RULE `(u == 1) (mod a) ==> coprime(a,u)`] THEN
    CONJ_TAC THENL [ASM_MESON_TAC[CONG_COPRIME]; ALL_TAC] THEN
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [NOT_EXISTS_THM]) THEN
    REWRITE_TAC[GSYM NOT_EXISTS_THM; CONTRAPOS_THM] THEN
    MATCH_MP_TAC MONO_EXISTS THEN
    UNDISCH_TAC `(u:num == t) (mod b)` THEN CONV_TAC NUMBER_RULE;
    ALL_TAC] THEN
  MAP_EVERY X_GEN_TAC [`p:num`; `k:num`] THEN ASM_CASES_TAC `p = 2` THENL
   [ASM_REWRITE_TAC[PRIME_2] THEN
    ASM_CASES_TAC `k = 0` THEN ASM_REWRITE_TAC[ARITH] THEN
    ASM_CASES_TAC `k = 1` THEN ASM_REWRITE_TAC[ARITH] THEN
    ASM_CASES_TAC `k = 2` THEN ASM_REWRITE_TAC[ARITH] THENL
     [EXISTS_TAC `3` THEN CONV_TAC(ONCE_DEPTH_CONV COPRIME_CONV) THEN
      CONV_TAC NUM_REDUCE_CONV THEN
      REWRITE_TAC[CONG; NOT_EXISTS_THM] THEN
      X_GEN_TAC `n:num` THEN ONCE_REWRITE_TAC[GSYM MOD_EXP_MOD] THEN
      MP_TAC(ARITH_RULE `n MOD 4 < 4`) THEN SPEC_TAC(`n MOD 4`,`n:num`) THEN
      CONV_TAC EXPAND_CASES_CONV THEN CONV_TAC NUM_REDUCE_CONV;
      DISCH_TAC THEN EXISTS_TAC `3` THEN ASM_REWRITE_TAC[LT_LE] THEN
      MATCH_MP_TAC(MESON[COPRIME_REFL]
       `~(a = 1) /\ coprime(n,a) /\ P a n
        ==> ~(a = n) /\ coprime(n,a) /\ P a n`) THEN
      REWRITE_TAC[COPRIME_LEXP] THEN
      CONV_TAC(ONCE_DEPTH_CONV COPRIME_CONV) THEN CONV_TAC NUM_REDUCE_CONV THEN
      MP_TAC(ISPECL [`3`; `k:num`] QUADRATIC_RESIDUE_MODULO_POWER_2) THEN
      REWRITE_TAC[CONG] THEN CONV_TAC NUM_REDUCE_CONV THEN
      DISCH_THEN MATCH_MP_TAC THEN ASM_ARITH_TAC];
    REPEAT DISCH_TAC THEN MATCH_MP_TAC(SET_RULE
     `{x | P x /\ Q x /\ R x} PSUBSET {x | P x /\ Q x}
      ==> ?a. P a /\ Q a /\ ~R a`) THEN
    MATCH_MP_TAC CARD_PSUBSET_IMP THEN
    CONJ_TAC THENL [SET_TAC[]; MATCH_MP_TAC LT_IMP_NE] THEN
    MP_TAC(SPEC `p EXP k` COUNT_QUADRATIC_RESIDUES_MODULO_PRIMITIVE) THEN
    ASM_REWRITE_TAC[PRIMITIVE_ROOT_EXISTS; HAS_SIZE] THEN
    ANTS_TAC THENL [ASM_MESON_TAC[ODD_PRIME; PRIME_ODD]; ALL_TAC] THEN
    DISCH_THEN(SUBST1_TAC o CONJUNCT2) THEN
    ONCE_REWRITE_TAC[COPRIME_SYM] THEN ONCE_REWRITE_TAC[CONJ_SYM] THEN
    REWRITE_TAC[GSYM PHI_ALT] THEN
    REWRITE_TAC[ARITH_RULE `n DIV 2 < n <=> ~(n = 0)`] THEN
    REWRITE_TAC[PHI_EQ_0; EXP_EQ_0; ARITH_EQ] THEN ASM_MESON_TAC[PRIME_0]]);;


