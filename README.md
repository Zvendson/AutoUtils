# AutoUtils

A small library which I will extend over time with tools
i need working around AutoIt 3.

Currently covered are:
* **Vector**: C++ like vectors without using <Array.au3> and ofc not typesafe
* **Prefixed Arrays**: Arrays that auto resize if needed and have the array size always at index 0. Mainly used for Unique IDs, where ID = Index.
* **Callback Arrays**: like Prefixed Arrays but fixed size holding subarrays which can have different sizes. The only purpose is to hold callbacks for an ID-Based event system, where one event can have multiple callbacks.