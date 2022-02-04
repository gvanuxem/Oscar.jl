@testset "finite fields" begin
   @testset for p in [2, 3]
      for F in [Nemo.GaloisField(UInt(p)), Nemo.GaloisFmpzField(fmpz(p))]
         f = Oscar.iso_oscar_gap(F)
         for a in F
            for b in F
               @test f(a*b) == f(a)*f(b)
               @test f(a-b) == f(a)-f(b)
            end
         end
      end
   end

   @testset for (p,d) in [(2, 1), (5, 1), (2, 4), (3, 3)]
      for F in [FqFiniteField(fmpz(p),d,:z), FqFiniteField(fmpz(p),d,:z)]
         f = Oscar.iso_oscar_gap(F)
         g = elm -> map_entries(f, elm)
         for a in F
            for b in F
               @test f(a*b) == f(a)*f(b)
               @test f(a-b) == f(a)-f(b)
            end
         end
         G = GL(4,F)
         for a in gens(G)
            for b in gens(G)
               @test g(a.elm*b.elm) == g(a.elm)*g(b.elm)
               @test g(a.elm-b.elm) == g(a.elm)-g(b.elm)
            end
         end
      end
   end
end

@testset "a large non-prime field (FqNmodFiniteField)" begin
   # (The defining polynomial of the Oscar field is not a Conway polynomial,
   # the polynomial of the GAP field is a Conway polynomial,
   # thus we need an intermediate field on the Oscar side.)
   p = next_prime(10^6)
   F = GF(p, 2)
   f = Oscar.iso_oscar_gap(F)
   for x in [ F(3), gen(F) ]
      a = f(x)
      @test preimage(f, a) == x
   end
   @test GAP.Globals.DefiningPolynomial(codomain(f)) ==
         GAP.Globals.ConwayPolynomial(p, 2)
   @test F.is_conway == 0
end

@testset "field of rationals" begin
  iso = Oscar.iso_oscar_gap(QQ)
  x = QQ(2//3)
  y = QQ(1)
  ox = iso(x)
  oy = iso(y)
  for i in 1:10
    xi = x^i
    oxi = iso(xi)
    @test preimage(iso, oxi) == xi
    @test oxi == ox^i
    @test oxi + oy == iso(xi + y)
  end
end

@testset "cyclotomic fields" begin
   # for computing random elements of the fields in question
   my_rand_bits(F::FlintRationalField, b::Int) = rand_bits(F, b)
   my_rand_bits(F::AnticNumberField, b::Int) = F([rand_bits(QQ, b) for i in 1:degree(F)])

   fields = Any[CyclotomicField(n) for n in [1, 3, 4, 5, 8, 15, 45]]
   push!(fields, (QQ, 1))

   @testset for (F, z) in fields
      f = Oscar.iso_oscar_gap(F)
      g = elm -> map_entries(f, elm)
      for i in 1:10
         a = my_rand_bits(F, 5)
         for j in 1:10
            b = my_rand_bits(F, 5)
            @test f(a*b) == f(a)*f(b)
            @test f(a - b) == f(a) - f(b)
         end
      end
   end
end