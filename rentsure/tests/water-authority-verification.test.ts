import { describe, it, expect, beforeEach } from "vitest"

const adminAddress = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"

const mockContract = {
  admin: adminAddress,
  verifiedAuthorities: new Map<string, boolean>(),
  authorityAddedAt: new Map<string, number>(),
  authorityAddedBy: new Map<string, string>(),

  isAdmin(caller: string) {
    return caller === this.admin
  },

  addAuthority(caller: string, authority: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    if (this.verifiedAuthorities.has(authority)) return { error: 101 }

    this.verifiedAuthorities.set(authority, true)
    this.authorityAddedAt.set(authority, Date.now())
    this.authorityAddedBy.set(authority, caller)

    return { value: true }
  },

  removeAuthority(caller: string, authority: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    if (caller === authority) return { error: 103 }
    if (!this.verifiedAuthorities.has(authority)) return { error: 102 }

    this.verifiedAuthorities.delete(authority)
    this.authorityAddedAt.delete(authority)
    this.authorityAddedBy.delete(authority)

    return { value: true }
  },

  transferAdmin(caller: string, newAdmin: string) {
    if (!this.isAdmin(caller)) return { error: 100 }
    if (caller === newAdmin) return { error: 104 }

    this.admin = newAdmin
    return { value: true }
  },

  isVerifiedAuthority(who: string) {
    return this.verifiedAuthorities.has(who)
  },

  listAuthorityMeta(who: string) {
    return {
      verified: this.isVerifiedAuthority(who),
      addedAt: this.authorityAddedAt.get(who) ?? null,
      addedBy: this.authorityAddedBy.get(who) ?? null
    }
  },

  reset() {
    this.admin = adminAddress
    this.verifiedAuthorities.clear()
    this.authorityAddedAt.clear()
    this.authorityAddedBy.clear()
  }
}

describe("Water Authority Access Control Contract", () => {
  beforeEach(() => {
    mockContract.reset()
  })

  it("allows admin to add a verified authority and stores metadata", () => {
    const result = mockContract.addAuthority(adminAddress, "ST2A")
    expect(result).toEqual({ value: true })

    expect(mockContract.isVerifiedAuthority("ST2A")).toBe(true)

    const meta = mockContract.listAuthorityMeta("ST2A")
    expect(meta.verified).toBe(true)
    expect(meta.addedBy).toBe(adminAddress)
    expect(typeof meta.addedAt).toBe("number")
  })

  it("prevents non-admin from adding authority", () => {
    const result = mockContract.addAuthority("ST2A", "ST2B")
    expect(result).toEqual({ error: 100 })
  })

  it("prevents adding an already verified authority", () => {
    mockContract.addAuthority(adminAddress, "ST2A")
    const result = mockContract.addAuthority(adminAddress, "ST2A")
    expect(result).toEqual({ error: 101 })
  })

  it("removes an existing authority and cleans metadata", () => {
    mockContract.addAuthority(adminAddress, "ST2A")
    const result = mockContract.removeAuthority(adminAddress, "ST2A")
    expect(result).toEqual({ value: true })
    expect(mockContract.isVerifiedAuthority("ST2A")).toBe(false)

    const meta = mockContract.listAuthorityMeta("ST2A")
    expect(meta.verified).toBe(false)
    expect(meta.addedAt).toBeNull()
    expect(meta.addedBy).toBeNull()
  })

  it("prevents non-admin from removing authority", () => {
    const result = mockContract.removeAuthority("ST2Z", "ST2A")
    expect(result).toEqual({ error: 100 })
  })

  it("prevents removing non-existent authority", () => {
    const result = mockContract.removeAuthority(adminAddress, "ST9X")
    expect(result).toEqual({ error: 102 })
  })

  it("prevents admin from removing themselves", () => {
    const result = mockContract.removeAuthority(adminAddress, adminAddress)
    expect(result).toEqual({ error: 103 })
  })

  it("transfers admin and allows new admin to act", () => {
    const transferResult = mockContract.transferAdmin(adminAddress, "STNEW")
    expect(transferResult).toEqual({ value: true })

    const result = mockContract.addAuthority("STNEW", "ST3X")
    expect(result).toEqual({ value: true })

    const meta = mockContract.listAuthorityMeta("ST3X")
    expect(meta.verified).toBe(true)
  })

  it("prevents transferring admin to self", () => {
    const result = mockContract.transferAdmin(adminAddress, adminAddress)
    expect(result).toEqual({ error: 104 })
  })
})
