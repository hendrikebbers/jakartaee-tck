/*
 * Copyright (c) 2007, 2018 Oracle and/or its affiliates. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0, which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the
 * Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
 * version 2 with the GNU Classpath Exception, which is available at
 * https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 */

/*
 * $Id$
 */

package com.sun.ts.tests.ejb30.bb.session.stateless.callback.listener.descriptor;

import javax.ejb.EJBContext;
import javax.ejb.Remote;
import javax.ejb.SessionContext;
import javax.ejb.Stateless;
import javax.annotation.Resource;

import com.sun.ts.tests.ejb30.common.callback.Callback2IF;
import com.sun.ts.tests.ejb30.common.callback.Callback2BeanBase;

@Stateless(name = "Callback2Bean")
@Remote({ Callback2IF.class })
// @Interceptors(
// {StatelessCallbackListener2.class}
// )
public class Callback2Bean extends Callback2BeanBase implements Callback2IF {
  private boolean postConstructOrPreDestroyCalled;

  @Resource
  private SessionContext sctx;

  public Callback2Bean() {
    super();
  }

  public EJBContext getEJBContext() {
    return this.sctx;
  }

  // ================== business methods ====================================

}
