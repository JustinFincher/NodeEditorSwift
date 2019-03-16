//
//  Extensions.swift
//  ShaderNodeEditor
//
//  Created by Justin Fincher on 16/3/2019.
//  Copyright © 2019 ZHENG HAOTIAN. All rights reserved.
//

import Foundation


public extension NSObject
{
    public class func getClassHierarchy() -> [AnyClass] {
        var hierarcy = [AnyClass]()
        hierarcy.append(self.classForCoder())
        var currentSuper: AnyClass? = class_getSuperclass(self.classForCoder())
        while currentSuper != nil {
            hierarcy.append(currentSuper!)
            currentSuper = class_getSuperclass(currentSuper)
        }
        
        return hierarcy
    }
    
    public class func getAllClasses() -> [AnyClass] {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        var classes = [AnyClass]()
        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)] {
                classes.append(currentClass)
            }
        }
        
        allClasses.deallocate()
        return classes
    }

    public class func directSubclasses() -> [AnyClass]
    {
        var result: Array<AnyClass> = []
        
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        for i in 0 ..< actualClassCount
        {
            if let currentClass: AnyClass = allClasses[Int(i)]
            {
                if let currentSuper = class_getSuperclass(currentClass)
                {
                    if (String(describing: currentSuper) == String(describing: self))
                    {
                        result.append(currentClass)
                    }
                }
            }
        }
        allClasses.deallocate()
        return result
    }
}
