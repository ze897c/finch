//
//  Group.swift
//  finch
//
//  Created by Matthew Patterson on 6/11/18.
//  Copyright © 2018 octeps. All rights reserved.
//
//

/// Definition
/// The axioms for a group are short and natural... Yet somehow hidden behind these axioms is the monster simple group, a huge and extraordinary mathematical object, which appears to rely on numerous bizarre coincidences to exist. The axioms for groups give no obvious hint that anything like this exists.
///
/// Richard Borcherds in Mathematicians: An Outer View of the Inner World [4]
///
/// A group is a set, G, together with an operation • (called the group law of G) that combines any two elements a and b to form another element, denoted a • b or ab. To qualify as a group, the set and operation, (G, •), must satisfy four requirements known as the group axioms:[5]
///
/// Closure
/// For all a, b in G, the result of the operation, a • b, is also in G.b[›]
/// Associativity
/// For all a, b and c in G, (a • b) • c = a • (b • c).
/// Identity element
/// There exists an element e in G such that, for every element a in G, the equation e • a = a • e = a holds. Such an element is unique (see below), and thus one speaks of the identity element.
/// Inverse element
/// For each a in G, there exists an element b in G, commonly denoted a−1 (or −a, if the operation is denoted "+"), such that a • b = b • a = e, where e is the identity element.
///
/// The result of an operation may depend on the order of the operands. In other words, the result of combining element a with element b need not yield the same result as combining element b with element a; the equation
///
/// a • b = b • a
///
/// may not always be true. This equation always holds in the group of integers under addition, because a + b = b + a for any two integers (commutativity of addition). Groups for which the commutativity equation a • b = b • a always holds are called abelian groups (in honor of Niels Henrik Abel). The symmetry group described in the following section is an example of a group that is not abelian.
///
/// The identity element of a group G is often written as 1 or 1G,[6] a notation inherited from the multiplicative identity. If a group is abelian, then one may choose to denote the group operation by + and the identity element by 0; in that case, the group is called an additive group. The identity element can also be written as id.
///
/// The set G is called the underlying set of the group (G, •). Often the group's underlying set G is used as a short name for the group (G, •). Along the same lines, shorthand expressions such as "a subset of the group G" or "an element of group G" are used when what is actually meant is "a subset of the underlying set G of the group (G, •)" or "an element of the underlying set G of the group (G, •)". Usually, it is clear from the context whether a symbol like G refers to a group or to an underlying set.

import Foundation
