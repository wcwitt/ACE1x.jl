
using ACE1x, ACE1, Test 

using ACE1: PolyTransform, transformed_jacobi, SparsePSHDegree, BasicPSH1pBasis, evaluate 
using ACE1.Random: rand_vec 
using ACE1.Testing: print_tf 
using LinearAlgebra: qr, norm, Diagonal, I
using SparseArrays
using JuLIP 

##

ord = 4
maxdeg = 15
r0 = 1.0
rin = 0.5
rcut = 3.0
zX = AtomicNumber(:X)
pcut = 2 
pin = 2
D = SparsePSHDegree()

trans = PolyTransform(1, r0)

ninc = (pcut + pin) * (ord-1)
maxn = maxdeg + ninc 
Pr = transformed_jacobi(maxn, trans, rcut, rin; pcut = pcut, pin = pin)
species = [ zX,]

## 

rpibasis = ACE1x.Pure2b.pure2b_basis(species = species, 
                                       Rn=Pr, 
                                       D=D, 
                                       maxdeg=maxdeg, 
                                       order=ord, 
                                       delete2b = true)


spec = ACE1.get_nl(rpibasis)

##

tol = 1e-12 # this seems crude but is needed because of roundoff errors
            # in the larger degree basis functions 

@info("Test evaluate of dimer = 0")
for ntest = 1:30 
   r = ACE1.rand_radial(Pr)
   Rs, Zs, z0 = [ JVecF(r, 0, 0), ], [ zX, ], zX 
   B = ACE1.evaluate(rpibasis, Rs, Zs, z0)
   print_tf(@test( norm(B, Inf) < 1e-12 )) 
end
println() 

## 

@info("Test energy of dimer = 0")
for ntest = 1:30 
   r = ACE1.rand_radial(Pr)
   at = Atoms(X = [ JVecF(0, 0, 0), JVecF(r, 0, 0) ], 
            Z = [ zX, zX ], 
            cell = [5.0 0 0; 0 5.0 0; 0 0.0 5.0], 
            pbc = false)
   B = energy(rpibasis, at)
   print_tf(@test( norm(B, Inf) < 1e-12 )) 
end
println() 

## 

@info("Confirm that invariance is preserved")

@info("Test energy of dimer = 0")
for ntest = 1:30 
   nat = 10 
   Rs = [ ACE1.rand_radial(Pr) * ACE1.Random.rand_sphere() for _=1:nat]
   Zs = fill(zX, nat)
   
   Rs1, Zs1 = ACE1.Random.rand_sym(Rs, Zs)
   
   print_tf(@test( evaluate(rpibasis, Rs,  Zs,  zX) ≈ 
                   evaluate(rpibasis, Rs1, Zs1, zX) ))
end
println() 