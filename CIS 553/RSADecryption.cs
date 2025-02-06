using System;
using System.Numerics;

class RSADecryption
{
    // Extended Euclidean Algorithm to find multiplicative inverse
    static BigInteger ExtendedEuclidean(BigInteger a, BigInteger b, out BigInteger x, out BigInteger y)
    {
        if (a == 0)
        {
            x = 0;
            y = 1;
            return b;
        }

        BigInteger x1, y1;
        BigInteger gcd = ExtendedEuclidean(b % a, a, out x1, out y1);

        x = y1 - (b / a) * x1;
        y = x1;

        return gcd;
    }

    // Square and Multiply algorithm for efficient exponentiation
    static BigInteger SquareAndMultiply(BigInteger baseNum, BigInteger exponent, BigInteger modulus)
    {
        BigInteger result = 1;
        while (exponent > 0)
        {
            if (exponent % 2 == 1)
                result = (result * baseNum) % modulus;
            baseNum = (baseNum * baseNum) % modulus;
            exponent /= 2;
        }
        return result;
    }

    // Chinese Remainder Theorem (CRT) decryption
    static BigInteger CRTDecryption(BigInteger c, BigInteger p, BigInteger q, BigInteger d)
    {
        BigInteger dp = d % (p - 1);
        BigInteger dq = d % (q - 1);
        BigInteger qInv = ExtendedEuclidean(q, p, out _, out _) % p;

        BigInteger m1 = SquareAndMultiply(c % p, dp, p);
        BigInteger m2 = SquareAndMultiply(c % q, dq, q);
        BigInteger h = (qInv * (m1 - m2)) % p;

        if (h < 0)
            h += p;

        return m2 + h * q;
    }

    static void Main(string[] args)
    {
        if (args.Length != 7)
        {
            Console.WriteLine("Usage: RSADecryption <ciphertext> <p> <q> <d> <e> <n>");
            return;
        }

        BigInteger c = BigInteger.Parse(args[0]);
        BigInteger p = BigInteger.Parse(args[1]);
        BigInteger q = BigInteger.Parse(args[2]);
        BigInteger d = BigInteger.Parse(args[3]);
        BigInteger e = BigInteger.Parse(args[4]);
        BigInteger n = BigInteger.Parse(args[5]);

        BigInteger plaintext = CRTDecryption(c, p, q, d);
        Console.WriteLine("Decrypted plaintext: " + plaintext);
    }
}
