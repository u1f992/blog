import decimal


def decimal_sin(ctx: decimal.Context, x: decimal.Decimal) -> decimal.Decimal:
    s = ctx.add(decimal.Decimal(0), x)
    term = x
    n = 1
    one = decimal.Decimal(1)
    while True:
        n += 1
        term = ctx.multiply(
            term,
            ctx.divide(ctx.multiply(-x, x), decimal.Decimal((2 * n - 2) * (2 * n - 1))),
        )
        s = ctx.add(s, term)
        if abs(term) < one / (10**ctx.prec):
            break
    return s

ctx = decimal.Context(prec=50)
x = decimal.Decimal("1")
print(decimal_sin(ctx, x))
