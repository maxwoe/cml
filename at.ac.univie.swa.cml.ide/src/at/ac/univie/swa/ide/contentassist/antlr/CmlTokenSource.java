/*
 * generated by Xtext 2.16.0
 */
package at.ac.univie.swa.ide.contentassist.antlr;

import at.ac.univie.swa.ide.contentassist.antlr.internal.InternalCmlParser;
import org.antlr.runtime.Token;
import org.antlr.runtime.TokenSource;
import org.eclipse.xtext.parser.antlr.AbstractIndentationTokenSource;

public class CmlTokenSource extends AbstractIndentationTokenSource {

	public CmlTokenSource(TokenSource delegate) {
		super(delegate);
	}

	@Override
	protected boolean shouldSplitTokenImpl(Token token) {
		// TODO Review assumption
		return token.getType() == InternalCmlParser.RULE_WS;
	}

	@Override
	protected int getBeginTokenType() {
		// TODO Review assumption
		return InternalCmlParser.RULE_BEGIN;
	}

	@Override
	protected int getEndTokenType() {
		// TODO Review assumption
		return InternalCmlParser.RULE_END;
	}

	@Override
	protected boolean shouldEmitPendingEndTokens() {
		return false;
	}
}
